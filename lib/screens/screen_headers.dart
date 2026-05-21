import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;
  final List<Widget>? actions;
  final double expandedHeight;
  final bool pinned;

  const GradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
    this.actions,
    this.expandedHeight = 150,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      backgroundColor: colors.first,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(children: [
                    Text(emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.80))),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
        title: Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }
}
