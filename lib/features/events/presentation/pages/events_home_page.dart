import 'package:flutter/material.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/presentation/pages/settings_home_page.dart';
import '../widgets/floating_search_field.dart';
import '../widgets/past_events_view.dart';
import '../widgets/upcoming_events_view.dart';

class EventsHomePage extends StatefulWidget {
  const EventsHomePage({super.key});

  @override
  State<EventsHomePage> createState() => _EventsHomePageState();
}

class _EventsHomePageState extends State<EventsHomePage> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _searching = false;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(loc.eventsPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsHomePage()),
              );
            },
          ),
        ],
      ),
      body: MaxWidthBody(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            UpcomingEventsView(query: _query),
            PastEventsView(query: _query),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxControlWidth),
              child: _searching
                  ? FloatingSearchField(
                      controller: _searchController,
                      hintText: loc.searchHint,
                      onChanged: (value) => setState(() => _query = value),
                      onClose: _closeSearch,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Material(
                            elevation: 3,
                            color: colors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(28),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SegmentButton(
                                      label: loc.tabUpcoming,
                                      selected: _selectedIndex == 0,
                                      onTap: () =>
                                          setState(() => _selectedIndex = 0),
                                    ),
                                  ),
                                  Expanded(
                                    child: _SegmentButton(
                                      label: loc.tabPast,
                                      selected: _selectedIndex == 1,
                                      onTap: () =>
                                          setState(() => _selectedIndex = 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          elevation: 3,
                          color: colors.surfaceContainerHigh,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.search),
                            tooltip: loc.tabSearch,
                            onPressed: () => setState(() => _searching = true),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
