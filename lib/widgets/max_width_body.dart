import 'package:flutter/material.dart';

/// The width every screen's main content is capped at. Past this, rows with
/// a leading label and a trailing value (list tiles, info rows) end up with
/// an awkward stretch of empty space between them - most noticeable in
/// landscape, where the screen is wide but short.
const double kMaxContentWidth = 760;

/// The width small floating controls (e.g. the home tab pill) are capped
/// at - narrower than [kMaxContentWidth] since a control shouldn't grow as
/// wide as a list or a reading column.
const double kMaxControlWidth = 380;

/// Wraps a screen's body so it never grows past [kMaxContentWidth]: on
/// narrow/portrait screens this is a no-op (the content is already
/// narrower), and on wide/landscape screens it centers the content instead
/// of letting it stretch edge-to-edge.
class MaxWidthBody extends StatelessWidget {
  const MaxWidthBody({
    super.key,
    required this.child,
    this.maxWidth = kMaxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
