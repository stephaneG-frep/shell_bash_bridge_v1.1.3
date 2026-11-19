import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ShellBadge extends StatelessWidget {
  final String shell;
  const ShellBadge({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String label;
    switch (shell.toLowerCase()) {
      case 'bash':
        bgColor = AppTheme.bashGreen;
        label = '\$';
        break;
      case 'powershell':
        bgColor = AppTheme.psBlue;
        label = 'PS>';
        break;
      default:
        bgColor = AppTheme.accent;
        label = '\$ ↔ PS>';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bgColor.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: TextStyle(color: bgColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
