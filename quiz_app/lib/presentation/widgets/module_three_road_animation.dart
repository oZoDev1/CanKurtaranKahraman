import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/constants/app_colors.dart';

class ModuleThreeRoadAnimation extends StatefulWidget {
  final int totalQuestions;
  final int completedCount;
  final VoidCallback onComplete;

  const ModuleThreeRoadAnimation({
    super.key,
    required this.totalQuestions,
    required this.completedCount,
    required this.onComplete,
  });

  @override
  State<ModuleThreeRoadAnimation> createState() => _ModuleThreeRoadAnimationState();
}

class _ModuleThreeRoadAnimationState extends State<ModuleThreeRoadAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _movementAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _movementAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Ufak bir gecikme
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Eğer tüm sorular bittiyse (modül sonuysa) konfeti patlat
    if (widget.completedCount == widget.totalQuestions) {
      _confettiController.play();
    }
    
    await _controller.forward();
    
    // Animasyon tamamlandıktan sonra bekle ve ekranı kapat
    await Future.delayed(const Duration(milliseconds: 600));
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
    final totalNodes = widget.totalQuestions;

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
                    widget.completedCount == widget.totalQuestions
                        ? 'Modül 3 Tamamlandı! 🎉'
                        : 'Harika! İlerliyoruz... 🚗',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Yol ve Noktalar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final roadWidth = constraints.maxWidth - 40;
                      // Yolun başlangıcı 0. nokta (sol kenar), sonu totalQuestions. nokta (sağ kenar)
                      final segmentWidth = roadWidth / (totalNodes > 0 ? totalNodes : 1);

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
                                  15,
                                  (index) => Container(
                                    width: 12,
                                    height: 2,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Soruları temsil eden Noktalar (1-based index)
                            ...List.generate(totalNodes, (index) {
                              final questionNum = index + 1;
                              // Noktalar sağdan sola dizilir
                              final xPos = roadWidth - questionNum * segmentWidth;
                              
                              final isPassed = questionNum < widget.completedCount;
                              final isTarget = questionNum == widget.completedCount;

                              Color nodeColor = Colors.grey.shade400;
                              if (isPassed) {
                                nodeColor = AppColors.correct;
                              } else if (isTarget) {
                                nodeColor = Colors.orangeAccent;
                              }

                              return Positioned(
                                left: xPos - 15, // Merkezlemek için
                                top: 40,
                                child: SizedBox(
                                  width: 30,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Nokta çemberi
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: nodeColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: isTarget
                                              ? [
                                                  const BoxShadow(
                                                    color: Colors.orangeAccent,
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: isPassed
                                            ? const Icon(Icons.check,
                                                size: 12, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(height: 6),
                                      // Soru Numarası
                                      Text(
                                        '$questionNum',
                                        style: TextStyle(
                                          fontSize: 10,
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
                            
                            // Arabamız
                            AnimatedBuilder(
                              animation: _movementAnimation,
                              builder: (context, child) {
                                // Başlangıç X: roadWidth - (completedCount - 1) * segmentWidth
                                final startX = roadWidth - (widget.completedCount - 1) * segmentWidth;
                                // Bitiş X: roadWidth - completedCount * segmentWidth
                                final endX = roadWidth - widget.completedCount * segmentWidth;
                                
                                final currentX = startX + (endX - startX) * _movementAnimation.value;

                                return Positioned(
                                  left: currentX - 33.75, // Arabayı merkezlemek için (67.5 / 2 = 33.75)
                                  top: 3,
                                  child: child!,
                                );
                              },
                              child: SizedBox(
                                width: 67.5,
                                height: 47.25,
                                child: Image.asset(
                                  'assets/images/Car.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Eğer görsel yüklenemezse fallback araba ikonu
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.directions_car,
                                        color: Colors.white,
                                        size: 30,
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
                ],
              ),
            ),
          ),
          
          // Konfeti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
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
