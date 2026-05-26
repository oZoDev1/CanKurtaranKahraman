import 'package:equatable/equatable.dart';

class Option extends Equatable {
  final int id;
  final int questionId;
  final String optionText;
  final bool isCorrect;
  final String? imagePath;

  const Option({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
    this.imagePath,
  });

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      id: map['id'],
      questionId: map['question_id'],
      optionText: map['option_text'],
      isCorrect: map['is_correct'] == 1,
      imagePath: map['image_path'],
    );
  }

  @override
  List<Object?> get props => [id, questionId, optionText, isCorrect, imagePath];
}
