import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every image asset referenced in lib/ is bundled', () async {
    final pattern = RegExp(r"'(assets/[^']+\.(?:png|jpg|jpeg|webp))'");
    final paths = <String>{
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File && file.path.endsWith('.dart'))
          for (final m in pattern.allMatches(file.readAsStringSync()))
            m.group(1)!,
    };
    expect(paths, isNotEmpty);
    for (final path in paths) {
      await expectLater(rootBundle.load(path), completes, reason: path);
    }
  });
}
