import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ordering_item.dart';
import '../../../core/services/sound_service.dart';

class ListOrderingQuestionWidget extends StatefulWidget {
  final List<OrderingItem> items;
  final Function(bool isCorrect) onAnswerSelected;

  const ListOrderingQuestionWidget({
    super.key,
    required this.items,
    required this.onAnswerSelected,
  });

  @override
  State<ListOrderingQuestionWidget> createState() => _ListOrderingQuestionWidgetState();
}

class _ListOrderingQuestionWidgetState extends State<ListOrderingQuestionWidget> {
  // Slot index (0-based) -> yerleştirilen öğe
  late Map<int, OrderingItem?> _slots;
  // Henüz yerleştirilmemiş (sürüklenebilir) öğeler
  late List<OrderingItem> _availableItems;

  bool _hasError = false;
  Set<int> _wrongSlotIndices = {};

  @override
  void initState() {
    super.initState();
    _slots = {for (int i = 0; i < widget.items.length; i++) i: null};
    _availableItems = List.from(widget.items)..shuffle();
  }

  void _checkAnswer() {
    bool isCorrect = true;
    Set<int> wrongSlots = {};

    for (int slotIndex = 0; slotIndex < widget.items.length; slotIndex++) {
      final placedItem = _slots[slotIndex];
      if (placedItem == null) {
        isCorrect = false;
        wrongSlots.add(slotIndex);
      } else if (placedItem.correctOrder != slotIndex + 1) {
        isCorrect = false;
        wrongSlots.add(slotIndex);
      }
    }

    if (_slots.values.any((v) => v == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm seçenekleri yerleştiriniz!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (isCorrect) {
      widget.onAnswerSelected(true);
    } else {
      setState(() {
        _hasError = true;
        _wrongSlotIndices = wrongSlots;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _hasError = false;
            _wrongSlotIndices = {};
          });
        }
      });
      widget.onAnswerSelected(false);
    }
  }

  void _placeItem(int slotIndex, OrderingItem item) {
    setState(() {
      _slots.forEach((key, value) {
        if (value?.id == item.id) {
          _slots[key] = null;
        }
      });

      final existingItem = _slots[slotIndex];
      if (existingItem != null) {
        _availableItems.add(existingItem);
      }

      _slots[slotIndex] = item;
      _availableItems.removeWhere((i) => i.id == item.id);
    });
  }

  void _removeFromSlot(int slotIndex) {
    setState(() {
      final item = _slots[slotIndex];
      if (item != null) {
        _availableItems.add(item);
        _slots[slotIndex] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol Kısım: Sürüklenebilir Seçenekler
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _availableItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Draggable<OrderingItem>(
                            data: item,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Opacity(
                                opacity: 0.9,
                                child: _buildDraggableItem(item, isDragging: true),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildDraggableItem(item),
                            ),
                            child: _buildDraggableItem(item),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Sağ Kısım: Boş Yuvalar
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(widget.items.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildDropSlot(index),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Onayla Butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () async {
              SoundService.instance.playButtonClick();
              await Future.delayed(const Duration(milliseconds: 150));
              _checkAnswer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.confirmButton,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Sıralamayı Onayla ✓',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDraggableItem(OrderingItem item, {bool isDragging = false}) {
    final imagePath = item.dragImagePath;
    final width = isDragging ? 140.0 : double.infinity;
    
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imagePath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                imagePath,
                height: isDragging ? 80 : 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: isDragging ? 80 : 100,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.itemText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDragging ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropSlot(int slotIndex) {
    final isWrong = _hasError;
    final placedItem = _slots[slotIndex];
    final isSlotWrong = isWrong && _wrongSlotIndices.contains(slotIndex);

    return DragTarget<OrderingItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        _placeItem(slotIndex, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          decoration: BoxDecoration(
            color: isSlotWrong
                ? AppColors.wrong.withOpacity(0.1)
                : isHovering
                    ? AppColors.primary.withOpacity(0.1)
                    : placedItem != null
                        ? Colors.white
                        : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSlotWrong
                  ? AppColors.wrong
                  : isHovering
                      ? AppColors.primary
                      : placedItem != null
                          ? Colors.transparent
                          : Colors.grey.shade300,
              width: isSlotWrong ? 2.5 : isHovering ? 2.0 : 2.0,
            ),
            boxShadow: placedItem != null
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: placedItem != null
              ? _buildPlacedItem(slotIndex, placedItem)
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      '${slotIndex + 1}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPlacedItem(int slotIndex, OrderingItem item) {
    return GestureDetector(
      onTap: () => _removeFromSlot(slotIndex),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Numara etiketi ve silme ikonu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${slotIndex + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(Icons.close, size: 16, color: Colors.grey),
                ],
              ),
            ),
            if (item.dragImagePath != null)
              Image.asset(
                item.dragImagePath!,
                height: 70,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(height: 70),
              ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                item.itemText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
