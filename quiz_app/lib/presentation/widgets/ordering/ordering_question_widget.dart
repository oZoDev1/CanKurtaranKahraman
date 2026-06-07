import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ordering_item.dart';
import '../../../core/services/sound_service.dart';

/// Dondurma topu renk görselleri – şıklara sırayla atanır.
const List<String> _scoopAssets = [
  'assets/images/scoop_pink.png',
  'assets/images/scoop_blue.png',
  'assets/images/scoop_yellow.png',
  'assets/images/scoop_green.png',
  'assets/images/scoop_orange.png',
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

class _OrderingQuestionWidgetState extends State<OrderingQuestionWidget> {
  // Her drop yuvası için yerleştirilen öğe (null = boş)
  late Map<int, OrderingItem?> _slots; // slot index (0-based) -> item
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

    // Boş slot varsa kullanıcıyı uyar
    if (_slots.values.any((v) => v == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm dondurmaları yerleştiriniz!'),
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

  /// Bir öğeyi slot'a yerleştir
  void _placeItem(int slotIndex, OrderingItem item) {
    setState(() {
      // Eğer bu dondurma zaten başka bir slot'taysa, oradan çıkar
      _slots.forEach((key, value) {
        if (value?.id == item.id) {
          _slots[key] = null;
        }
      });

      // Eğer hedef slot doluysa, oradaki dondurmayı geri available'a koy
      final existingItem = _slots[slotIndex];
      if (existingItem != null) {
        _availableItems.add(existingItem);
      }

      // Dondurmayı slot'a yerleştir
      _slots[slotIndex] = item;

      // Available listesinden çıkar
      _availableItems.removeWhere((i) => i.id == item.id);
    });
  }

  /// Bir öğeyi slot'tan geri çıkar
  void _removeFromSlot(int slotIndex) {
    setState(() {
      final item = _slots[slotIndex];
      if (item != null) {
        _availableItems.add(item);
        _slots[slotIndex] = null;
      }
    });
  }

  String _getScoopAsset(int index) {
    return _scoopAssets[index % _scoopAssets.length];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final itemCount = widget.items.length;

    // Şık sayısına ve ekran yüksekliğine göre boyutları ölçeklendiriyoruz
    final isCompact = itemCount > 3 || screenHeight < 700;
    final scoopSize = isCompact ? 70.0 : 80.0;
    
    // Külah boyutları
    final coneWidth = scoopSize * 1.15;
    final coneHeight = coneWidth * 1.25;

    return Column(
      children: [
        const SizedBox(height: 8),

        // ── DONDURMA TOPLARI ALANI (Drag Zone) ──
        Expanded(
          child: _buildScoopArea(scoopSize, itemCount),
        ),

        const SizedBox(height: 12),

        // ── DONDURMA KULESİ (Drop Zone) ──
        _buildIceCreamCone(scoopSize, coneHeight, itemCount),

        const SizedBox(height: 16),

        // ── ONAYLA BUTONU ──
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

  Offset _getSlotOffset(int slotIndex, double scoopSize, double coneHeight) {
    // 1 numaralı yuvayı (sağdaki sarı top gibi) referans alarak konumlandırıyoruz
    final double baseLeft = scoopSize * 0.60;
    final double baseBottom = coneHeight - scoopSize * 0.70;

    if (slotIndex == 0) {
      // 1 numara: en altta sağa yakın (mevcut dikey hizası korundu)
      return Offset(baseLeft, baseBottom);
    } else if (slotIndex == 1) {
      // 2 numara: 1 numaranın sol çaprazında ve birazcık aşağısında (görseldeki yeşil top gibi)
      return Offset(
        baseLeft - scoopSize * 0.55,
        baseBottom - scoopSize * 0.08,
      );
    } else if (slotIndex == 2) {
      // 3 numara: 2 numara ile 1 numaranın tam yatay ortasına hizalanmış ve kesişim yerine daha yakın olması için aşağı indirildi
      return Offset(
        baseLeft - scoopSize * 0.275,
        baseBottom + scoopSize * 0.45,
      );
    } else {
      // 4 ve 5 numara (varsa): 3 numaranın üzerine dikey yığılmaya devam eder
      final double scoopOverlap = scoopSize * 0.40;
      return Offset(
        baseLeft - scoopSize * 0.275,
        baseBottom + scoopSize * 0.45 + (slotIndex - 2) * (scoopSize - scoopOverlap),
      );
    }
  }

  /// Dondurma külahı ve üst üste binen drop yuvaları (Görsel referanslı üçgen yapısı)
  Widget _buildIceCreamCone(double scoopSize, double coneHeight, int itemCount) {
    final isWrong = _hasError;
    final double coneWidth = scoopSize * 1.15;
    
    // En yüksek yuvanın bottom koordinatına göre container yüksekliğini dinamik belirliyoruz
    double maxBottom = 0;
    for (int i = 0; i < itemCount; i++) {
      final offset = _getSlotOffset(i, scoopSize, coneHeight);
      if (offset.dy > maxBottom) {
        maxBottom = offset.dy;
      }
    }
    final double towerHeight = maxBottom + scoopSize + 10.0;
    final double towerWidth = scoopSize * 1.7;

    return SizedBox(
      width: towerWidth,
      height: towerHeight,
      child: Stack(
        children: [
          // Külah (En altta, bottom: 0, sol koordinatı iki topu ortalayacak şekilde hizalandı)
          Positioned(
            bottom: 0,
            left: scoopSize * 0.25,
            width: coneWidth,
            height: coneHeight,
            child: Image.asset(
              'assets/images/ice_cream_cone.png',
              fit: BoxFit.contain,
            ),
          ),

          // Üst üste binen dondurma yuvaları
          ...List.generate(itemCount, (slotIndex) {
            final placedItem = _slots[slotIndex];
            final isSlotWrong = isWrong && _wrongSlotIndices.contains(slotIndex);

            final offset = _getSlotOffset(slotIndex, scoopSize, coneHeight);

            return Positioned(
              left: offset.dx,
              bottom: offset.dy,
              width: scoopSize,
              height: scoopSize,
              child: DragTarget<OrderingItem>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  _placeItem(slotIndex, details.data);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovering = candidateData.isNotEmpty;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isSlotWrong
                          ? AppColors.wrong.withOpacity(0.2)
                          : isHovering
                              ? AppColors.primary.withOpacity(0.25)
                              : placedItem != null
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSlotWrong
                            ? AppColors.wrong
                            : isHovering
                                ? AppColors.primary
                                : placedItem != null
                                    ? Colors.transparent
                                    : Colors.grey.shade400.withOpacity(0.8),
                        width: isSlotWrong ? 3.5 : isHovering ? 2.5 : placedItem != null ? 0.0 : 2.0,
                      ),
                      boxShadow: [
                        if (isSlotWrong)
                          BoxShadow(
                            color: AppColors.wrong.withOpacity(0.4),
                            blurRadius: 8,
                          )
                        else if (isHovering)
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 6,
                          )
                        else if (placedItem == null)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                      ],
                    ),
                    child: placedItem != null
                        ? _buildPlacedScoop(slotIndex, placedItem, scoopSize)
                        : _buildEmptySlot(slotIndex, scoopSize),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Boş dondurma yuvası içeriği
  Widget _buildEmptySlot(int slotIndex, double size) {
    return Center(
      child: Text(
        '${slotIndex + 1}',
        style: TextStyle(
          fontSize: size * 0.3,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  /// Dolu yuvadaki dondurma topu
  Widget _buildPlacedScoop(int slotIndex, OrderingItem item, double size) {
    final originalIndex = widget.items.indexWhere((i) => i.id == item.id);
    final scoopAsset = _getScoopAsset(originalIndex);

    return GestureDetector(
      onTap: () => _removeFromSlot(slotIndex),
      child: ClipOval(
        child: Stack(
          children: [
            // Dondurma topu görseli
            Positioned.fill(
              child: Image.asset(
                scoopAsset,
                fit: BoxFit.cover,
              ),
            ),
            // Ortalanmış gölgeli beyaz yazı
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    item.itemText,
                    style: TextStyle(
                      fontSize: (size * 0.17).clamp(10.0, 15.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(-1.2, -1.2),
                          color: Colors.black.withOpacity(0.9),
                        ),
                        Shadow(
                          offset: const Offset(1.2, -1.2),
                          color: Colors.black.withOpacity(0.9),
                        ),
                        Shadow(
                          offset: const Offset(1.2, 1.2),
                          color: Colors.black.withOpacity(0.9),
                        ),
                        Shadow(
                          offset: const Offset(-1.2, 1.2),
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seçenekler alanı (Drag zone)
  Widget _buildScoopArea(double scoopSize, int itemCount) {
    if (_availableItems.isEmpty) {
      return Center(
        child: Text(
          'Tüm dondurmalar yerleştirildi!\nSırayı kontrol et ve onayla.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textMain.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final dragScoopSize = scoopSize * 1.15;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _availableItems.map((item) {
            final originalIndex = widget.items.indexWhere((i) => i.id == item.id);
            final scoopAsset = _getScoopAsset(originalIndex);

            return Draggable<OrderingItem>(
              data: item,
              feedback: Material(
                color: Colors.transparent,
                child: _buildScoopCard(item, scoopAsset, dragScoopSize, isDragging: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildScoopCard(item, scoopAsset, dragScoopSize),
              ),
              child: _buildScoopCard(item, scoopAsset, dragScoopSize),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Tekil dondurma topu kartı
  Widget _buildScoopCard(OrderingItem item, String scoopAsset, double size, {bool isDragging = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      color: Colors.transparent,
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Görsel
            Positioned.fill(
              child: Opacity(
                opacity: isDragging ? 0.7 : 1.0,
                child: Image.asset(
                  scoopAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Ortalanmış gölgeli beyaz yazı
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    item.itemText,
                    style: TextStyle(
                      fontSize: (size * 0.16).clamp(11.0, 16.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(-1.5, -1.5),
                          color: Colors.black.withOpacity(0.9),
                        ),
                        Shadow(
                          offset: const Offset(1.5, -1.5),
                          color: Colors.black.withOpacity(0.9),
                        ),
                        Shadow(
                          offset: const Offset(1.5, 1.5),
                          color: Colors.black.withOpacity(0.9),
                        ),
                        Shadow(
                          offset: const Offset(-1.5, 1.5),
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
