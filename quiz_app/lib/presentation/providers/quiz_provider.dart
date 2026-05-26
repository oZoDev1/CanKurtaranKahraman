import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/question.dart';
import '../../data/database/database_helper.dart';

class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final int correctCount;
  final bool isLoading;
  final Map<int, String> moduleTitles; // quiz_group_id -> title

  QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.isLoading = true,
    this.moduleTitles = const {},
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? correctCount,
    bool? isLoading,
    Map<int, String>? moduleTitles,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      isLoading: isLoading ?? this.isLoading,
      moduleTitles: moduleTitles ?? this.moduleTitles,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(QuizState()) {
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final db = await DatabaseHelper.instance.database;

    // Modül başlıklarını yükle
    final groupMaps = await db.query('quiz_groups', orderBy: 'id');
    final titles = <int, String>{};
    for (final g in groupMaps) {
      titles[g['id'] as int] = g['title'] as String;
    }

    // Soruları yükle
    final questionMaps = await db.query('questions');
    final allQuestions = questionMaps.map((m) => Question.fromMap(m)).toList();

    // Modüle göre grupla, modül sırasını koru, içinde karıştır
    final grouped = <int, List<Question>>{};
    for (final q in allQuestions) {
      grouped.putIfAbsent(q.quizGroupId, () => []).add(q);
    }

    final sortedKeys = grouped.keys.toList()..sort();
    final orderedQuestions = <Question>[];
    for (final key in sortedKeys) {
      final group = grouped[key]!;
      group.shuffle();
      orderedQuestions.addAll(group);
    }

    state = state.copyWith(
      questions: orderedQuestions,
      moduleTitles: titles,
      isLoading: false,
    );
  }

  void nextQuestion(bool isCorrect) {
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
    );
  }

  Future<void> restart() async {
    state = QuizState(); // isLoading: true, index: 0, correct: 0
    await _loadQuestions(); // Tekrar yükle + karıştır
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});
