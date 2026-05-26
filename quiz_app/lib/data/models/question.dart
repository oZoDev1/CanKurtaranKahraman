import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final int id;
  final String type; // 'test', 'ordering', 'true_false'
  final String questionText;
  final bool? correctAnswerBool;
  final String? explanation;
  final int quizGroupId;

  const Question({
    required this.id,
    required this.type,
    required this.questionText,
    this.correctAnswerBool,
    this.explanation,
    required this.quizGroupId,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      type: map['type'],
      questionText: map['question_text'],
      correctAnswerBool: map['correct_answer_bool'] != null
          ? map['correct_answer_bool'] == 1
          : null,
      explanation: map['explanation'],
      quizGroupId: map['quiz_group_id'],
    );
  }

  @override
  List<Object?> get props => [id, type, questionText, correctAnswerBool, explanation, quizGroupId];
}
