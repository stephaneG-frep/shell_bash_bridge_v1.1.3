import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class TerminalContainer extends StatelessWidget {
  final String text;
  final String? prompt;
  final bool isBash;
  const TerminalContainer({super.key, required this.text, this.prompt, this.isBash = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.terminalBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isBash ? AppTheme.bashGreen.withValues(alpha: 0.3) : AppTheme.psBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prompt != null)
            Text(prompt!, style: AppFonts.firaCode(color: isBash ? AppTheme.bashGreen : AppTheme.psBlue, fontSize: 12)),
          const SizedBox(height: 4),
          Text(text, style: AppFonts.firaCode(color: AppTheme.terminalText, fontSize: 13)),
        ],
      ),
    );
  }
}
