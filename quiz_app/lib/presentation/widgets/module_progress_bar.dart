import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/sound_service.dart';

/// Modül ilerlemesini gösteren dikey çubuk widget'ı.
/// Modüldeki toplam soru sayısına göre dilimlenmiş bir bar gösterir.
/// Doğru cevaplanan sorular aşağıdan yukarı doğru animasyonlu şekilde doldurulur.
class ModuleProgressBar extends StatefulWidget {
  final int totalQuestions;
  final int completedCount;
  final VoidCallback onAnimationComplete;

  const ModuleProgressBar({
    super.key,
    required this.totalQuestions,
    required this.completedCount,
    required this.onAnimationComplete,
  });

  @override
  State<ModuleProgressBar> createState() => _ModuleProgressBarState();
}

class _ModuleProgressBarState extends State<ModuleProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _fadeInController.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    // Bar doldurma sesini çal
    SoundService.instance.playBarFilling();

    await _fillController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    await _fadeOutController.forward();
    if (mounted) {
      widget.onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeInController, _fadeOutController, _fillController]),
      builder: (context, child) {
        double opacity = _fadeInController.value;
        if (_fadeOutController.value > 0) {
          opacity = 1.0 - _fadeOutController.value;
        }
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: _buildContent(context),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Başlık ve padding alanlarını çıkararak barın yüksekliğini güvenle hesaplayalım
    final availableHeight = screenHeight - 140; 
    final barHeight = (availableHeight * 0.85).clamp(100.0, screenHeight * 0.6);
    const barWidth = 44.0;
    final segmentCount = widget.totalQuestions;

    return Container(
      color: Colors.black54,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Başlık
              const Text(
                'Modül İlerlemesi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.completedCount} / $segmentCount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              // Dikey bar - SABİT YÜKSEKLİK ile overflow engelleniyor
              SizedBox(
                height: barHeight,
                width: barWidth + 20, // Parıltı efekti için ekstra alan
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Arka plan bar
                    Container(
                      width: barWidth,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: _buildSegments(segmentCount),
                      ),
                    ),
                    // Parıltı efekti (en son doldurulan segment üzerinde)
                    AnimatedBuilder(
                      animation: _fillController,
                      builder: (context, child) {
                        if (_fillController.value < 0.1) {
                          return const SizedBox();
                        }

                        final segmentHeight = barHeight / segmentCount;
                        // Yeni doldurulan segment'in alttan konumu
                        final previouslyFilled = widget.completedCount - 1;
                        final segmentBottom = previouslyFilled * segmentHeight;

                        return Positioned(
                          bottom: segmentBottom,
                          child: Opacity(
                            opacity: (1.0 - _fillController.value) * 0.8,
                            child: Container(
                              width: barWidth + 16,
                              height: segmentHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.correct.withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegments(int segmentCount) {
    final previouslyFilled = widget.completedCount - 1;

    // Normal Column (yukarıdan aşağı) ile render ediyoruz.
    // columnIndex 0 = ekranın EN ÜSTÜ -> son soru
    // columnIndex son = ekranın EN ALTI -> 1. soru
    return Column(
      children: List.generate(segmentCount, (columnIndex) {
        final questionIndex = segmentCount - 1 - columnIndex; // 0-based alttan yukarı

        final isFilledBefore = questionIndex < previouslyFilled;
        final isCurrentFilling = questionIndex == previouslyFilled;

        return Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dolu arka plan (önceden tamamlanmış sorular)
              if (isFilledBefore)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.correct.withOpacity(0.85),
                        AppColors.correct,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              
              // Animasyonlu dolma — aşağıdan yukarı
              if (isCurrentFilling)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedBuilder(
                    animation: _fillAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        heightFactor: _fillAnimation.value,
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.correct,
                                AppColors.correct.withOpacity(0.9),
                                const Color(0xFF66BB6A),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Segment ayırıcı çizgi (en alttaki hariç)
              if (columnIndex < segmentCount - 1)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1.5,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),

              // Soru numarası (alttan yukarı: 1, 2, 3, ...)
              if (segmentCount <= 10 ||
                  (questionIndex + 1) % 5 == 0 ||
                  questionIndex == 0 ||
                  questionIndex == segmentCount - 1)
                Center(
                  child: Text(
                    '${questionIndex + 1}',
                    style: TextStyle(
                      fontSize: segmentCount > 15 ? 8 : 10,
                      fontWeight: FontWeight.bold,
                      color: (isFilledBefore || isCurrentFilling)
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
