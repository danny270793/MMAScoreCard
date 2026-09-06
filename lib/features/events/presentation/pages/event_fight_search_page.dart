import 'package:flutter/material.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/event_fight.dart';
import '../../domain/entities/mma_event.dart';
import 'event_detail_page.dart';

class EventFightSearchPage extends StatefulWidget {
  const EventFightSearchPage({
    super.key,
    required this.event,
    required this.fights,
  });

  final MmaEvent event;
  final List<EventFight> fights;

  @override
  State<EventFightSearchPage> createState() => _EventFightSearchPageState();
}

class _EventFightSearchPageState extends State<EventFightSearchPage> {
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
        ? const <EventFight>[]
        : widget.fights
              .where(
                (f) =>
                    f.fighterA.toLowerCase().contains(query) ||
                    f.fighterB.toLowerCase().contains(query) ||
                    f.weightClass.toLowerCase().contains(query),
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
                itemBuilder: (context, index) => FightTile(
                  event: widget.event,
                  fight: results[index],
                  titleFightLabel: loc.eventDetailTitleFightLabel,
                ),
              ),
      ),
    );
  }
}
