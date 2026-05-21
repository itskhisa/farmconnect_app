import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';

// ── Farm Card (Theme-aware for dark mode) ────────────────────────────────────
class FarmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const FarmCard({super.key, required this.child, this.padding, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? const Color(0xFF1A2E1C) : Colors.white);
    final borderColor = isDark ? const Color(0xFF2A4A2D) : kBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : [
            BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// ── Stat Tile (Theme-aware) ───────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? icon;

  const StatTile({super.key, required this.label, required this.value,
      required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 4),
        Row(children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: Colors.white.withOpacity(0.88))),
        ]),
      ]),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.icon,
      this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        if (icon != null) ...[
          Text(icon!, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
        ],
        Text(title, style: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? kText)),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: kGreen, fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}

// ── Tag Chip ─────────────────────────────────────────────────────────────────
class TagChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const TagChip({super.key, required this.label,
      this.bg = kGreenPale, this.fg = kGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(
          fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Priority Chip ─────────────────────────────────────────────────────────────
class PriorityChip extends StatelessWidget {
  final String priority;
  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'high':   [kRed.withOpacity(0.12),   kRed],
      'medium': [kAmber.withOpacity(0.14),  kAmber],
      'low':    [kGreenPale,                kGreen],
    };
    final c = colors[priority] ?? colors['low']!;
    return TagChip(label: priority.toUpperCase(),
        bg: c[0] as Color, fg: c[1] as Color);
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'growing':   [kGreenPale, kGreen],
      'flowering': [kBlue.withOpacity(0.12), kBlue],
      'ready':     [kAmber.withOpacity(0.14), kAmber],
      'harvested': [Colors.grey.shade100, Colors.grey.shade500],
      'poor':      [kRed.withOpacity(0.10), kRed],
    };
    final c = colors[status] ?? colors['growing']!;
    return TagChip(label: status[0].toUpperCase() + status.substring(1),
        bg: c[0] as Color, fg: c[1] as Color);
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({super.key, required this.emoji, required this.title,
      required this.subtitle, this.buttonLabel, this.onButton});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? kText)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tTextMuted)),
          if (buttonLabel != null) ...[
            const SizedBox(height: 20),
            SizedBox(width: 200,
                child: ElevatedButton(
                    onPressed: onButton, child: Text(buttonLabel!))),
          ],
        ]),
      ),
    );
  }
}

// ── Labelled Field ────────────────────────────────────────────────────────────
class LabelledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? suffix;
  final int maxLines;
  final String? helperText;
  final bool isRequired;
  final bool numbersOnly;

  const LabelledField({
    super.key, required this.label, required this.hint,
    required this.controller, this.keyboardType,
    this.obscureText = false, this.errorText, this.suffix,
    this.maxLines = 1, this.helperText,
    this.isRequired = false, this.numbersOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(children: [
        TextSpan(text: label, style: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w600, color: context.tTextSec)),
        if (isRequired) const TextSpan(
            text: ' *', style: TextStyle(color: kRed, fontSize: 13,
                fontWeight: FontWeight.w700)),
      ])),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: numbersOnly ? TextInputType.number : keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        inputFormatters: numbersOnly
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : null,
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          helperText: helperText,
          helperStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextMuted),
          suffixIcon: suffix,
        ),
      ),
    ]);
  }
}

// ── Snackbar helpers ──────────────────────────────────────────────────────────
void showSuccess(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(msg)),
    ]),
    backgroundColor: kGreen,
  ));
}

void showError(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.error_outline, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(msg)),
    ]),
    backgroundColor: kRed,
  ));
}
