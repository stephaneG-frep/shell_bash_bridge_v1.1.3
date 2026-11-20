import 'package:flutter/material.dart';

/// Zone tactile accessible : comme GestureDetector, mais annoncée comme un bouton
/// par les lecteurs d'écran (TalkBack), avec son texte, son état sélectionné
/// et un libellé optionnel pour les boutons qui ne contiennent qu'une icône.
class Tappable extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final String? label;
  final bool? selected;

  const Tappable({super.key, required this.onTap, required this.child, this.label, this.selected});

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: onTap != null,
        selected: selected,
        label: label,
        child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: child),
      ),
    );
  }
}
