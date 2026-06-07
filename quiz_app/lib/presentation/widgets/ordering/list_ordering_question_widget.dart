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
  // Sabit sırada kalan karıştırılmış tüm öğeler
  late List<OrderingItem> _shuffledItems;

  bool _hasError = false;
  Set<int> _wrongSlotIndices = {};

  @override
  void initState() {
    super.initState();
    _slots = {for (int i = 0; i < widget.items.length; i++) i: null};
    _shuffledItems = List.from(widget.items)..shuffle();
  }

  @override
  void didUpdateWidget(covariant ListOrderingQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _slots = {for (int i = 0; i < widget.items.length; i++) i: null};
      _shuffledItems = List.from(widget.items)..shuffle();
      _hasError = false;
      _wrongSlotIndices = {};
    }
  }

  bool _isPlaced(OrderingItem item) {
    return _slots.values.any((placed) => placed?.id == item.id);
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

      _slots[slotIndex] = item;
    });
  }

  void _removeFromSlot(int slotIndex) {
    setState(() {
      _slots[slotIndex] = null;
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
              // Sol Kısım: Sürüklenebilir Seçenekler (Açıklamalar sabit kalır)
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _shuffledItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildLeftItem(item),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Sağ Kısım: Çember Yuvalar (Centering columns)
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(widget.items.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
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

  Widget _buildLeftItem(OrderingItem item) {
    final imagePath = item.dragImagePath;
    final isPlaced = _isPlaced(item);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Görsel Alanı (Çember şeklinde, dış kutu yok)
        if (imagePath != null)
          SizedBox(
            height: 90,
            width: 90,
            child: isPlaced
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 36),
                    ),
                  )
                : Draggable<OrderingItem>(
                    data: item,
                    feedback: Material(
                      color: Colors.transparent,
                      child: ClipOval(
                        child: Transform.scale(
                          scale: 1.4,
                          child: Image.asset(
                            imagePath,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: ClipOval(
                        child: Transform.scale(
                          scale: 1.4,
                          child: Image.asset(
                            imagePath,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Transform.scale(
                          scale: 1.4,
                          child: Image.asset(
                            imagePath,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          
        const SizedBox(height: 6),
        // Metin Alanı (Açıklama sabit kalır, sürüklenmez)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Opacity(
            opacity: isPlaced ? 0.4 : 1.0,
            child: Text(
              item.itemText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
        ),
      ],
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
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: isSlotWrong
                ? AppColors.wrong.withOpacity(0.1)
                : isHovering
                    ? AppColors.primary.withOpacity(0.1)
                    : placedItem != null
                        ? Colors.white
                        : Colors.grey.shade50,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSlotWrong
                  ? AppColors.wrong
                  : isHovering
                      ? AppColors.primary
                      : placedItem != null
                          ? AppColors.primary.withOpacity(0.5)
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
                  child: Text(
                    '${slotIndex + 1}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade300,
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
      child: ClipOval(
        child: Stack(
          children: [
            if (item.dragImagePath != null)
              Transform.scale(
                scale: 1.4,
                child: Image.asset(
                  item.dragImagePath!,
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            // Çarpı silme simgesi
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
