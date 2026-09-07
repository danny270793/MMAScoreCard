import 'package:flutter/material.dart';

/// Same background as [showModalBottomSheet]'s enclosing `Material`.
Color modalBottomSheetSurfaceColor(BuildContext context) {
  final theme = Theme.of(context);
  final bs = theme.bottomSheetTheme;
  final modal = bs.modalBackgroundColor;
  if (modal != null) return modal;
  final themed = bs.backgroundColor;
  if (themed != null) return themed;
  if (theme.useMaterial3) return theme.colorScheme.surfaceContainerLow;
  return theme.colorScheme.surface;
}

Widget modalBottomSheetBackButton(BuildContext context) => IconButton(
  icon: const Icon(Icons.arrow_back_rounded),
  onPressed: () => Navigator.maybePop(context),
  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
);

class BottomSheetPinnedTitleScrollView extends StatelessWidget {
  const BottomSheetPinnedTitleScrollView({
    super.key,
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetBg = modalBottomSheetSurfaceColor(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: CustomScrollView(
        shrinkWrap: true,
        physics: ScrollConfiguration.of(context).getScrollPhysics(context),
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            scrolledUnderElevation: 4,
            backgroundColor: sheetBg,
            shadowColor: theme.colorScheme.shadow,
            leading: modalBottomSheetBackButton(context),
            title: Text(title, style: theme.textTheme.titleLarge),
            actions: actions,
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(child: child),
          ),
        ],
      ),
    );
  }
}
