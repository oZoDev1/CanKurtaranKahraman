import 'package:equatable/equatable.dart';

class OrderingItem extends Equatable {
  final int id;
  final int questionId;
  final String itemText;
  final String? dragImagePath;
  final String? dropImagePath;
  final int correctOrder;

  const OrderingItem({
    required this.id,
    required this.questionId,
    required this.itemText,
    this.dragImagePath,
    this.dropImagePath,
    required this.correctOrder,
  });

  factory OrderingItem.fromMap(Map<String, dynamic> map) {
    return OrderingItem(
      id: map['id'],
      questionId: map['question_id'],
      itemText: map['item_text'],
      dragImagePath: map['drag_image_path'],
      dropImagePath: map['drop_image_path'],
      correctOrder: map['correct_order'],
    );
  }

  @override
  List<Object?> get props => [id, questionId, itemText, dragImagePath, dropImagePath, correctOrder];
}
