import 'package:flutter/material.dart';

/// Tombol utama selebar layar.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          );
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: outlined
          ? OutlinedButton(
              onPressed: loading ? null : onPressed,
              style: OutlinedButton.styleFrom(shape: shape),
              child: child)
          : FilledButton(
              onPressed: loading ? null : onPressed,
              style: FilledButton.styleFrom(shape: shape),
              child: child),
    );
  }
}
