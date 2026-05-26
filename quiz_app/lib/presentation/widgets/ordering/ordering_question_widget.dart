import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ordering_item.dart';

class OrderingQuestionWidget extends StatefulWidget {
  final List<OrderingItem> items;
  final Function(bool isCorrect) onAnswerSelected;

  const OrderingQuestionWidget({
    super.key,
    required this.items,
    required this.onAnswerSelected,
  });

  @override
  State<OrderingQuestionWidget> createState() => _OrderingQuestionWidgetState();
}

class _OrderingQuestionWidgetState extends State<OrderingQuestionWidget> {
  late List<OrderingItem> _currentOrder;
  bool _hasError = false;
  Set<int> _wrongItemIds = {};

  @override
  void initState() {
    super.initState();
    _currentOrder = List.from(widget.items)..shuffle();
  }

  void _checkAnswer() {
    bool isCorrect = true;
    Set<int> wrongIds = {};

    for (int i = 0; i < _currentOrder.length; i++) {
      if (_currentOrder[i].correctOrder != i + 1) {
        isCorrect = false;
        wrongIds.add(_currentOrder[i].id);
      }
    }

    if (isCorrect) {
      widget.onAnswerSelected(true);
    } else {
      setState(() {
        _hasError = true;
        _wrongItemIds = wrongIds;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _hasError = false;
            _wrongItemIds = {};
          });
        }
      });
      widget.onAnswerSelected(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth < 400 ? 80.0 : 110.0;

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _currentOrder.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _currentOrder.removeAt(oldIndex);
                _currentOrder.insert(newIndex, item);
              });
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final scale = Tween<double>(begin: 1.0, end: 1.08).animate(animation);
                  return Transform.scale(
                    scale: scale.value,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final item = _currentOrder[index];
              final isWrong = _hasError && _wrongItemIds.contains(item.id);
              final hasDragImage = item.dragImagePath != null && item.dragImagePath!.isNotEmpty;

              return AnimatedContainer(
                key: ValueKey(item.id),
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: isWrong ? AppColors.wrong.withOpacity(0.2) : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isWrong ? AppColors.wrong : Colors.grey.shade300,
                    width: isWrong ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isWrong ? AppColors.wrong.withOpacity(0.3) : Colors.black12,
                      blurRadius: isWrong ? 8 : 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Sürükleme ikonu
                      const Icon(Icons.drag_indicator, color: Colors.grey, size: 28),
                      const SizedBox(width: 8),
                      // Sıra numarası
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isWrong ? AppColors.wrong : AppColors.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isWrong ? Colors.white : AppColors.textMain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Görsel veya metin
                      if (hasDragImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            item.dragImagePath!,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Görsel bulunamazsa metin göster
                              return Container(
                                width: imageSize,
                                height: imageSize,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    item.itemText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMain,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            item.itemText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                      // Yanlış işareti
                      if (isWrong)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.close, color: AppColors.wrong, size: 28),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.confirmButton,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Sıralamayı Onayla ✓',
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
