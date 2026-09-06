import 'package:flutter/material.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/fighter_profile.dart';
import 'fighter_detail_page.dart';

class FighterFightSearchPage extends StatefulWidget {
  const FighterFightSearchPage({super.key, required this.fights});

  final List<FighterFightRecord> fights;

  @override
  State<FighterFightSearchPage> createState() => _FighterFightSearchPageState();
}

class _FighterFightSearchPageState extends State<FighterFightSearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final query = _query.trim().toLowerCase();
    final results = query.isEmpty
        ? const <FighterFightRecord>[]
        : widget.fights
              .where(
                (f) =>
                    f.opponentName.toLowerCase().contains(query) ||
                    f.eventName.toLowerCase().contains(query),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: loc.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: MaxWidthBody(
        child: query.isEmpty
            ? Center(child: Text(loc.searchEmptyPrompt))
            : results.isEmpty
            ? Center(child: Text(loc.searchNoResults))
            : ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 16),
                itemBuilder: (context, index) =>
                    FightHistoryTile(record: results[index]),
              ),
      ),
    );
  }
}
