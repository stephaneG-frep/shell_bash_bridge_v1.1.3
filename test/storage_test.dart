import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_bash_bridge/services/storage_service.dart';

void main() {
  test('progression corrompue -> pas de crash', () async {
    SharedPreferences.setMockInitialValues({'user_progress': '{pas du json', 'user_notes': '[{"id":1,"createdAt":"xx"}, 42]'});
    await StorageService.init();
    expect(StorageService.loadProgress().completedLessons, isEmpty);
    final notes = StorageService.loadNotes();
    expect(notes.length, 1);
    expect(notes.first.id, '1');
  });
  test('mauvais types -> ignorés', () async {
    SharedPreferences.setMockInitialValues({'user_progress': '{"completedLessons":{"bash_001":true,"x":"oui"},"scores":"no","bashProgress":"a"}'});
    await StorageService.init();
    final p = StorageService.loadProgress();
    expect(p.completedLessons, {'bash_001': true});
    expect(p.bashProgress, 0.0);
  });
  test('progression valide relue', () async {
    SharedPreferences.setMockInitialValues({'user_progress': '{"completedLessons":{"bash_001":true},"badges":["Premier terminal"],"bashProgress":0.5}'});
    await StorageService.init();
    final p = StorageService.loadProgress();
    expect(p.badges, ['Premier terminal']);
    expect(p.bashProgress, 0.5);
  });
}
