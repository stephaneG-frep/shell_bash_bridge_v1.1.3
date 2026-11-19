import '../../core/app_fonts.dart';
import 'package:flutter/material.dart';

import '../../data/bash_courses.dart';
import '../../data/powershell_courses.dart';
import '../../models/note.dart';
import '../../services/storage_service.dart';
import '../../core/theme.dart';

class NotesScreen extends StatefulWidget {
  /// Si renseigné : n'affiche que les notes de cette leçon et y rattache les nouvelles.
  final String? lessonId;
  final String? lessonTitle;
  const NotesScreen({super.key, this.lessonId, this.lessonTitle});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _allNotes = []; // toutes les notes (base des enregistrements)
  List<Note> _notes = []; // notes affichées (éventuellement filtrées par leçon)

  static final Map<String, String> _lessonTitles = {
    for (final c in [...BashCourseData.allCourses, ...PowerShellCourseData.allCourses])
      for (final l in c.lessons) l.id: l.title,
  };
  bool _isEditing = false;
  Note? _editingNote;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    // Depuis une leçon sans note : ouvrir directement l'éditeur.
    if (widget.lessonId != null && _notes.isEmpty) _createNewNote();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    setState(() {
      _allNotes = StorageService.loadNotes();
      _notes = widget.lessonId == null
          ? List.of(_allNotes)
          : _allNotes.where((n) => n.lessonId == widget.lessonId).toList();
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  void _createNewNote() {
    _titleController.text = widget.lessonTitle ?? '';
    _contentController.clear();
    setState(() {
      _isEditing = true;
      _editingNote = null;
    });
  }

  void _editNote(Note note) {
    _titleController.text = note.title;
    _contentController.text = note.content;
    setState(() {
      _isEditing = true;
      _editingNote = note;
    });
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La note ne peut pas être vide',
              style: AppFonts.firaCode(fontSize: 12),
            ),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
      return;
    }

    final now = DateTime.now();
    final notes = List<Note>.from(_allNotes);

    if (_editingNote != null) {
      final index = notes.indexWhere((n) => n.id == _editingNote!.id);
      if (index != -1) {
        notes[index] = Note(
          id: _editingNote!.id,
          title: title.isEmpty ? 'Sans titre' : title,
          content: content,
          lessonId: _editingNote!.lessonId,
          createdAt: _editingNote!.createdAt,
          updatedAt: now,
        );
      }
    } else {
      notes.add(Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.isEmpty ? 'Sans titre' : title,
        content: content,
        lessonId: widget.lessonId ?? '',
        createdAt: now,
        updatedAt: now,
      ));
    }

    await StorageService.saveNotes(notes);
    setState(() {
      _isEditing = false;
      _editingNote = null;
    });
    _loadNotes();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Note enregistrée',
            style: AppFonts.firaCode(fontSize: 12),
          ),
          backgroundColor: AppTheme.safe,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingNote = null;
    });
    _titleController.clear();
    _contentController.clear();
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Supprimer la note',
          style: AppFonts.firaCode(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer "${note.title}" ?',
          style: AppFonts.firaCode(
            fontSize: 12,
            color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Annuler',
              style: AppFonts.firaCode(
                fontSize: 12,
                color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Supprimer',
              style: AppFonts.firaCode(
                fontSize: 12,
                color: AppTheme.danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notes = List<Note>.from(_allNotes);
      notes.removeWhere((n) => n.id == note.id);
      await StorageService.saveNotes(notes);
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardBg(context),
      body: SafeArea(
        child: _isEditing ? _buildEditor() : _buildNotesList(),
      ),
      floatingActionButton: _isEditing
          ? null
          : FloatingActionButton(
              onPressed: _createNewNote,
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
    );
  }

  Widget _buildNotesList() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _notes.isEmpty ? _buildEmptyState() : _buildList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.lessonTitle != null ? 'Notes : ${widget.lessonTitle}' : 'Mes Notes',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.firaCode(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_notes.length}',
              style: AppFonts.firaCode(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_alt_rounded,
                size: 48,
                color: AppTheme.accent.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune note',
              style: AppFonts.firaCode(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer\nvotre première note',
              style: AppFonts.firaCode(
                fontSize: 12,
                color: AppTheme.textSecColor(context).withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildNoteCard(note),
        );
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    final preview = note.content.length > 100
        ? '${note.content.substring(0, 100)}...'
        : note.content;

    final dateStr =
        '${note.updatedAt.day.toString().padLeft(2, '0')}/${note.updatedAt.month.toString().padLeft(2, '0')}/${note.updatedAt.year}';

    return GestureDetector(
      onTap: () => _editNote(note),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.chipBg(context).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.textSecColor(context).withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.note_alt_rounded,
                color: AppTheme.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: AppFonts.firaCode(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (preview.isNotEmpty)
                    Text(
                      preview,
                      style: AppFonts.firaCode(
                        fontSize: 11,
                        color: AppTheme.textSecColor(context).withValues(alpha: 0.45),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (widget.lessonId == null && _lessonTitles[note.lessonId] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 11, color: AppTheme.accent.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _lessonTitles[note.lessonId]!,
                            style: AppFonts.firaCode(fontSize: 10, color: AppTheme.accent.withValues(alpha: 0.8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    dateStr,
                    style: AppFonts.firaCode(
                      fontSize: 9,
                      color: AppTheme.textSecColor(context).withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: AppTheme.danger.withValues(alpha: 0.6),
              onPressed: () => _deleteNote(note),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          color: AppTheme.cardBg(context),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
                color: AppTheme.textSecColor(context).withValues(alpha: 0.7),
                onPressed: _cancelEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _editingNote != null ? 'Modifier la note' : 'Nouvelle note',
                  style: AppFonts.firaCode(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: _saveNote,
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enregistrer',
                  style: AppFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: AppFonts.firaCode(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Titre de la note',
                    hintStyle: AppFonts.firaCode(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecColor(context).withValues(alpha: 0.2),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                ),
                Container(
                  height: 1,
                  color: AppTheme.textSecColor(context).withValues(alpha: 0.08),
                ),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 400),
                  child: TextField(
                    controller: _contentController,
                    style: AppFonts.firaCode(
                      fontSize: 14,
                      color: AppTheme.textSecColor(context).withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Écrivez votre note ici...',
                      hintStyle: AppFonts.firaCode(
                        fontSize: 14,
                        color: AppTheme.textSecColor(context).withValues(alpha: 0.2),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
