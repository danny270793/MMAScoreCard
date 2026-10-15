#!/usr/bin/env python3
"""Builds MMAScoreCard/Resources/Localizable.xcstrings from the Flutter .arb files.

Keys stay the same as the Flutter app; ICU placeholders become positional
arguments in the order they appear in the English string (%n$lld for `int`
placeholders, %n$@ otherwise), and ICU
plurals become String Catalog plural variations. Strings only the Swift app
needs live in swift_only_strings.json next to this script.

Usage: python3 -I swift/scripts/arb_to_xcstrings.py
"""
import json
import pathlib
import re

here = pathlib.Path(__file__).resolve().parent
swift = here.parent
arb_dir = swift.parent / "flutter" / "lib" / "l10n"
out = swift / "MMAScoreCard" / "Resources" / "Localizable.xcstrings"

langs = {"en": json.loads((arb_dir / "app_en.arb").read_text()),
         "es": json.loads((arb_dir / "app_es.arb").read_text())}
extra = json.loads((here / "swift_only_strings.json").read_text())
placeholder = re.compile(r"\{(\w+)\}")
plural = re.compile(r"^\{(\w+), plural, (.*)\}$", re.S)


def convert(text, order, types):
    def spec(m):
        name = m.group(1)
        return f"%{order.index(name) + 1}${'lld' if types.get(name) == 'int' else '@'}"
    return placeholder.sub(spec, text.replace("%", "%%"))


def plural_cases(body):
    """'=1{1 win} other{{count} wins}' -> {'=1': '1 win', 'other': '{count} wins'}"""
    cases, i = {}, 0
    while i < len(body):
        m = re.compile(r"\s*(=?\w+)\{").match(body, i)
        if not m:
            break
        depth, j = 1, m.end()
        while depth:
            depth += {"{": 1, "}": -1}.get(body[j], 0)
            j += 1
        cases[m.group(1)] = body[m.end():j - 1]
        i = j
    return cases


def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


def localization(value, order, types):
    m = plural.match(value)
    if not m:
        return unit(convert(value, order, types))
    variations = {}
    for case, text in plural_cases(m.group(2)).items():
        variations[{"=0": "zero", "=1": "one"}.get(case, case)] = unit(convert(text, order, types))
    return {"variations": {"plural": variations}}


strings = {}
for key, en in langs["en"].items():
    if key.startswith("@"):
        continue
    m = plural.match(en)
    order = [m.group(1)] if m else list(dict.fromkeys(placeholder.findall(en)))
    meta = langs["en"].get(f"@{key}", {}).get("placeholders", {})
    types = {name: p.get("type") for name, p in meta.items()}
    entry = {"extractionState": "manual", "localizations": {}}
    for lang, data in langs.items():
        entry["localizations"][lang] = localization(data.get(key, en), order, types)
    strings[key] = entry

for key, values in extra.items():
    strings[key] = {"extractionState": "manual",
                    "localizations": {lang: unit(v) for lang, v in values.items()}}

out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps({"sourceLanguage": "en", "strings": dict(sorted(strings.items())), "version": "1.0"},
                          ensure_ascii=False, indent=2) + "\n")
print(f"wrote {len(strings)} strings to {out.relative_to(swift.parent)}")
