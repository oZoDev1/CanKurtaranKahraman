import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/constants/app_colors.dart';

/// Yatay yol animasyonu widget'ı.
/// Modüller arası geçişte ambulansın bir önceki modül noktasından yeni modül noktasına gitmesini sağlar.
class HorizontalRoadAnimation extends StatefulWidget {
  final int totalModules;
  final int fromNodeIndex; // 0-based node index (0: Başlangıç, 1: Modül 1, vs.)
  final VoidCallback onComplete;

  const HorizontalRoadAnimation({
    super.key,
    required this.totalModules,
    required this.fromNodeIndex,
    required this.onComplete,
  });

  @override
  State<HorizontalRoadAnimation> createState() =>
      _HorizontalRoadAnimationState();
}

class _HorizontalRoadAnimationState extends State<HorizontalRoadAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _movementAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _movementAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Kısa bir bekleme
    await Future.delayed(const Duration(milliseconds: 500));
    _confettiController.play(); // Konfeti patlat!
    await _controller.forward();
    // Animasyon bitince biraz bekle ve bitir
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Toplam nokta sayısı = Modül Sayısı (Başlangıç noktası kaldırıldı)
    final totalNodes = widget.totalModules;

    return Container(
      color: Colors.black87,
      child: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Modül ${widget.fromNodeIndex + 1} Tamamlandı! ✅',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 2))
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Yol ve Noktalar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final roadWidth = constraints.maxWidth - 40;
                      final segmentWidth = roadWidth /
                          (widget.totalModules > 1 ? widget.totalModules - 1 : 1);

                      return SizedBox(
                        width: roadWidth,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          clipBehavior: Clip.none,
                          children: [
                            // Yol çizgisi (Arka plan)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 50,
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade600,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            // Yol kesik çizgileri
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 55,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  20,
                                  (index) => Container(
                                    width: 10,
                                    height: 2,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                            // Noktalar ve modül etiketleri
                            ...List.generate(totalNodes, (index) {
                              final xPos = roadWidth - (index * segmentWidth);
                              final isPassed = index <= widget.fromNodeIndex;
                              final isTarget = index == widget.fromNodeIndex + 1;

                              Color nodeColor = Colors.grey.shade400;
                              if (isPassed) {
                                nodeColor = AppColors.correct;
                              } else if (isTarget) {
                                nodeColor = Colors.orangeAccent;
                              }

                              return Positioned(
                                left: xPos - 30,
                                top: 40,
                                child: SizedBox(
                                  width: 60,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Nokta
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: nodeColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: isTarget
                                              ? [
                                                  const BoxShadow(
                                                    color: Colors.orangeAccent,
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: isPassed
                                            ? const Icon(Icons.check,
                                                size: 14, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(height: 6),
                                      // Modül etiketi
                                      Text(
                                        'M${index + 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPassed
                                              ? AppColors.correct
                                              : isTarget
                                                  ? Colors.orangeAccent
                                                  : Colors.grey.shade400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            // Ambulans
                            AnimatedBuilder(
                              animation: _movementAnimation,
                              builder: (context, child) {
                                final startX = roadWidth -
                                    (widget.fromNodeIndex * segmentWidth);
                                final endX = roadWidth -
                                    ((widget.fromNodeIndex + 1) * segmentWidth);
                                final currentX = startX +
                                    (endX - startX) * _movementAnimation.value;

                                return Positioned(
                                  left: currentX - 30,
                                  top: -10,
                                  child: child!,
                                );
                              },
                              child: SizedBox(
                                width: 80,
                                height: 60,
                                child: Image.asset(
                                  'assets/images/Ambulans.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4)
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.local_hospital,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Hedef modül bilgisi
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _controller.value > 0.5 ? 1.0 : 0.0,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Modül ${widget.fromNodeIndex + 2} Başlıyor!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ),
                ], // <-- 1. EKSİK PARANTEZ (Column children)
              ),   // <-- 2. EKSİK PARANTEZ (Column)
            ),     // <-- 3. EKSİK PARANTEZ (Center)
          ),       // <-- 4. EKSİK PARANTEZ (SafeArea)
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // Her yöne patlasın
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }
    }