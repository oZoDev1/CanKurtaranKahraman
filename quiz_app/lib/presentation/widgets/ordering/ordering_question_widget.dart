import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ordering_item.dart';
import '../../../core/services/sound_service.dart';

const List<String> _balloonAssets = [
  'assets/images/balloon_red.png',
  'assets/images/balloon_blue.png',
  'assets/images/balloon_yellow.png',
];

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

class _OrderingQuestionWidgetState extends State<OrderingQuestionWidget> with SingleTickerProviderStateMixin {
  late Map<int, OrderingItem?> _slots;
  late List<OrderingItem> _availableItems;
  bool _hasError = false;
  Set<int> _wrongSlotIndices = {};

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slots = {for (int i = 0; i < widget.items.length; i++) i: null};
    _availableItems = List.from(widget.items)..shuffle();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OrderingQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _slots = {for (int i = 0; i < widget.items.length; i++) i: null};
      _availableItems = List.from(widget.items)..shuffle();
      _hasError = false;
      _wrongSlotIndices = {};
      _slideController.reset();
    }
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
          content: Text('Lütfen tüm balonları vagonlara yerleştiriniz!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (isCorrect) {
      _slideController.forward().then((_) {
        widget.onAnswerSelected(true);
      });
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

  String _getBalloonAsset(int index) {
    return _balloonAssets[index % _balloonAssets.length];
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length;

    return Column(
      children: [
        const SizedBox(height: 8),

        // ── BALONLAR ALANI (Drag Zone) ──
        Expanded(
          child: _buildBalloonsArea(),
        ),

        const SizedBox(height: 16),

        // ── TREN VE VAGONLAR (Drop Zone) ──
        SlideTransition(
          position: _slideAnimation,
          child: _buildTrainArea(itemCount),
        ),

        const SizedBox(height: 16),

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

  Widget _buildBalloonsArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 2),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _availableItems.map((item) {
              final asset = _getBalloonAsset(item.correctOrder - 1);
              return Draggable<OrderingItem>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildBalloon(item, asset, isDragging: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildBalloon(item, asset),
                ),
                child: _buildBalloon(item, asset),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBalloon(OrderingItem item, String assetPath, {bool isDragging = false, bool inSlot = false}) {
    final size = isDragging ? 120.0 : 100.0;
    return Container(
      width: inSlot ? double.infinity : size,
      height: inSlot ? double.infinity : size * 1.2,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.contain,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            // Centering text visually in the middle of the balloon sphere
            bottom: inSlot ? 8.0 : size * 0.08,
            left: 8,
            right: 8,
          ),
          child: Text(
            item.itemText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDragging ? 14 : (inSlot ? 11 : 12),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 4,
                  offset: Offset(1.5, 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrainArea(int itemCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AspectRatio(
        aspectRatio: 1024 / 561,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            
            // Oranlar: Sarı Vagon (0.305), Mavi Vagon (0.49), Yeşil Vagon (0.675)
            final leftOffsets = [0.305, 0.49, 0.675];
            
            return Stack(
              children: [
                // Tren Arkaplanı
                Image.asset(
                  'assets/images/FullTren.png',
                  width: w,
                  height: h,
                  fit: BoxFit.contain,
                ),
                
                // Vagonların Üzerindeki Bırakma Yuvaları
                for (int i = 0; i < itemCount && i < 3; i++)
                  Positioned(
                    left: w * leftOffsets[i],
                    top: h * 0.45,
                    width: w * 0.165,
                    height: h * 0.28,
                    child: _buildDropSlot(i),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropSlot(int slotIndex) {
    final placedItem = _slots[slotIndex];
    final isWrong = _hasError && _wrongSlotIndices.contains(slotIndex);

    return DragTarget<OrderingItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        _placeItem(slotIndex, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return GestureDetector(
          onTap: () {
            if (placedItem != null) {
              _removeFromSlot(slotIndex);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isWrong
                  ? Colors.red.withOpacity(0.4)
                  : isHovering
                      ? Colors.blue.withOpacity(0.4)
                      : placedItem != null
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isWrong
                    ? Colors.red
                    : isHovering
                        ? Colors.blue
                        : placedItem != null
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: placedItem != null
                ? _buildBalloon(
                    placedItem,
                    _getBalloonAsset(placedItem.correctOrder - 1),
                    inSlot: true,
                  )
                : Center(
                    child: Text(
                      '${slotIndex + 1}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
