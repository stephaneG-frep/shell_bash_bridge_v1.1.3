import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_bash_bridge/features/notes/notes_screen.dart';
import 'package:shell_bash_bridge/services/storage_service.dart';

void main() {
  testWidgets('une note créée depuis une leçon y est rattachée sans effacer les autres',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_notes':
          '[{"id":"1","title":"Autre","content":"x","lessonId":"","createdAt":"2026-01-01T00:00:00.000","updatedAt":"2026-01-01T00:00:00.000"}]',
    });
    await StorageService.init();

    await tester.pumpWidget(const MaterialApp(
      home: NotesScreen(lessonId: 'bash_001', lessonTitle: 'Ma leçon'),
    ));
    await tester.pumpAndSettle();

    // Aucune note pour cette leçon : l'éditeur s'ouvre, titre prérempli.
    expect(find.text('Ma leçon'), findsWidgets);
    await tester.enterText(find.byType(TextField).last, 'Mon contenu');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final notes = StorageService.loadNotes();
    expect(notes.length, 2);
    expect(notes.firstWhere((n) => n.title == 'Autre').lessonId, '');
    expect(notes.firstWhere((n) => n.content == 'Mon contenu').lessonId, 'bash_001');
  });
}
