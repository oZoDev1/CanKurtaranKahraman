import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';

class TrueFalseQuestionWidget extends StatefulWidget {
  final bool correctAnswer;
  final Function(bool isCorrect) onAnswerSelected;
  final String questionText;

  const TrueFalseQuestionWidget({
    super.key,
    required this.correctAnswer,
    required this.onAnswerSelected,
    required this.questionText,
  });

  @override
  State<TrueFalseQuestionWidget> createState() => _TrueFalseQuestionWidgetState();
}

class _TrueFalseQuestionWidgetState extends State<TrueFalseQuestionWidget>
    with TickerProviderStateMixin {
  bool? _selectedAnswer;
  bool _isAnimating = false;
  bool _animationDone = false;
  bool? _lastResultCorrect;
  bool _wrongCallbackFired = false;

  // Basket girme animasyonu (doğru cevap) — aşağıdan yukarı çıkıp potadan aşağı girer
  late AnimationController _scoreController;
  late Animation<double> _scoreProgress; // 0.0 → 1.0 normalize ilerleme
  late Animation<double> _scoreOpacity;

  // Sekme animasyonu (yanlış cevap) — aşağıdan yukarı çıkıp potadan sekip sağa gider
  late AnimationController _bounceController;
  late Animation<double> _bounceProgress; // 0.0 → 1.0 normalize ilerleme
  late Animation<double> _bounceXAnimation;
  late Animation<double> _bounceRotation;

  @override
  void initState() {
    super.initState();

    // --- Doğru cevap: Top aşağıdan potanın üstüne çıkar, sonra aşağı inip girer ---
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Faz 1 (0→50%): Aşağıdan potanın üstüne yükselir (yavaşlayarak)
    // Faz 2 (50→100%): Potanın üstünden aşağı doğru iner (hızlanarak, yerçekimi)
    _scoreProgress = TweenSequence<double>([
      // Faz 1: 0.0 → 1.0 (aşağıdan potanın üstüne)
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.decelerate)),
        weight: 50,
      ),
      // Faz 2: 1.0 → 2.0 (potanın üstünden aşağı — potadan geçer)
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 2.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 50,
      ),
    ]).animate(_scoreController);

    _scoreOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 75),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_scoreController);

    // --- Yanlış cevap: Top aşağıdan potanın üstüne çıkar, potadan sekip sağa gider ---
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // Faz 1 (0→40%): Aşağıdan potanın üstüne yükselir
    // Faz 2 (40→55%): Potaya çarpıp hafif yukarı seker
    // Faz 3 (55→100%): Sağa savrularak aşağı düşer
    _bounceProgress = TweenSequence<double>([
      // Faz 1: 0.0 → 1.0 — aşağıdan potanın üstüne
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.decelerate)),
        weight: 40,
      ),
      // Faz 2: 1.0 → 0.85 — potadan sekme (hafif yukarı)
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      // Faz 3: 0.85 → 3.0 — sağa savrularak aşağı düşer
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 3.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 45,
      ),
    ]).animate(_bounceController);

    // X ekseni: Faz 1-2'de merkezde kalır, Faz 3'te sağa kayar
    _bounceXAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 55),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
    ]).animate(_bounceController);

    // Rotasyon: hafif döner, sonra savrulma sırasında hızlı döner
    _bounceRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.3), weight: 15),
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 2 * pi)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 45,
      ),
    ]).animate(_bounceController);

    _bounceController.addListener(() {
      if (_bounceController.value >= 0.90 &&
          _isAnimating &&
          _lastResultCorrect == false &&
          !_wrongCallbackFired) {
        _wrongCallbackFired = true;
        if (mounted) widget.onAnswerSelected(false);
      }
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onHoopSelected(bool selection) {
    if (_isAnimating) return;
    setState(() {
      _selectedAnswer = selection;
    });
  }

  void _confirm() {
    if (_selectedAnswer == null || _isAnimating) return;

    final isCorrect = _selectedAnswer == widget.correctAnswer;

    setState(() {
      _isAnimating = true;
      _lastResultCorrect = isCorrect;
    });

    if (isCorrect) {
      _scoreController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
            _animationDone = true;
          });
          widget.onAnswerSelected(true);
        }
      });
    } else {
      _wrongCallbackFired = false;
      _bounceController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
            _animationDone = true;
          });
          if (!_wrongCallbackFired) {
            _wrongCallbackFired = true;
            widget.onAnswerSelected(false);
          }
        }
      });
    }
  }

  void resetForRetry() {
    setState(() {
      _selectedAnswer = null;
      _animationDone = false;
      _lastResultCorrect = null;
      _wrongCallbackFired = false;
      _scoreController.reset();
      _bounceController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final hoopW = w * 0.30;
        final hoopH = h * 0.44;
        final ballSize = w * 0.12;
        final hoopTopY = h * 0.02;
        final leftHoopX = w * 0.03;
        final rightHoopX = w - hoopW - w * 0.03;
        final ballRestY = h * 0.72; // Ekranın orta-alt kısmı

        // Seçilen potanın merkez X'i
        double targetCenterX = w / 2;
        if (_selectedAnswer == true) targetCenterX = leftHoopX + hoopW / 2;
        if (_selectedAnswer == false) targetCenterX = rightHoopX + hoopW / 2;
        final targetTopY = hoopTopY + hoopH * 0.45; // Pota çemberi seviyesi

        // Soru kutusu konumu: iki potanın ortası, potaların biraz altı
        final questionTopY = hoopTopY + hoopH * 0.55;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Arkaplan
            Positioned.fill(
              child: Image.asset(
                'assets/images/arkaplan.png',
                fit: BoxFit.cover,
              ),
            ),

            // "İFADELERİ DOĞRU POTAYA ATINIZ" başlık
            Positioned(
              top: hoopTopY + 4,
              left: leftHoopX + hoopW,
              right: w - rightHoopX,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'İFADELERİ DOĞRU\nPOTAYA ATINIZ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // DOĞRU Pota (Sol)
            Positioned(
              left: leftHoopX,
              top: hoopTopY,
              width: hoopW,
              height: hoopH,
              child: GestureDetector(
                onTap: () => _onHoopSelected(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: _selectedAnswer == true
                        ? Border.all(color: Colors.greenAccent, width: 4)
                        : null,
                    boxShadow: _selectedAnswer == true
                        ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 16, spreadRadius: 2)]
                        : null,
                  ),
                  child: Image.asset('assets/images/dogru.png', fit: BoxFit.contain),
                ),
              ),
            ),

            // YANLIŞ Pota (Sağ)
            Positioned(
              left: rightHoopX,
              top: hoopTopY,
              width: hoopW,
              height: hoopH,
              child: GestureDetector(
                onTap: () => _onHoopSelected(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: _selectedAnswer == false
                        ? Border.all(color: Colors.redAccent, width: 4)
                        : null,
                    boxShadow: _selectedAnswer == false
                        ? [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 16, spreadRadius: 2)]
                        : null,
                  ),
                  child: Image.asset('assets/images/yanlis.png', fit: BoxFit.contain),
                ),
              ),
            ),

            // Soru kutusu — iki potanın ortasında, onayla butonunun eski konumunda
            Positioned(
              left: leftHoopX + hoopW - 12,
              right: w - rightHoopX - 12,
              top: questionTopY + h * 0.04,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Question speech bubble
                  Padding(
                    padding: const EdgeInsets.only(left: 36.0, bottom: 10.0),
                    child: CustomPaint(
                      painter: QuestionBubblePainter(color: Colors.white.withOpacity(0.92)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          top: 10.0,
                          bottom: 22.0, // extra padding for the tail
                        ),
                        child: Text(
                          _extractQuestionText(widget.questionText),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // 2. Thinking Robot image at bottom-left
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/3.png',
                      width: 45,
                      height: 45,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // ONAYLA butonu — ekranın sağ alt tarafında
            Positioned(
              right: 12,
              bottom: h * 0.06,
              child: ElevatedButton(
                onPressed: (_selectedAnswer == null || _isAnimating) ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.confirmButton,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 22),
                    SizedBox(width: 6),
                    Text('ONAYLA',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // --- Statik Top (animasyon yokken) — ekranın orta-alt kısmında ---
            if (!_isAnimating)
              Positioned(
                left: w / 2 - ballSize / 2,
                top: ballRestY,
                child: Image.asset('assets/images/top.png', width: ballSize, height: ballSize),
              ),

            // --- Animasyonlu Top ---
            // Doğru cevap: aşağıdan potanın üstüne çıkar, sonra potadan geçerek aşağı iner
            if (_isAnimating && _lastResultCorrect == true)
              AnimatedBuilder(
                animation: _scoreController,
                builder: (context, child) {
                  final progress = _scoreProgress.value;
                  double ballY;
                  if (progress <= 1.0) {
                    // Faz 1: orta-alttan (ballRestY) potanın üstüne yükselir
                    final aboveHoopY = targetTopY - ballSize * 1.5;
                    ballY = ballRestY + (aboveHoopY - ballRestY) * progress;
                  } else {
                    // Faz 2: potanın üstünden aşağı doğru iner (potadan geçer)
                    final aboveHoopY = targetTopY - ballSize * 1.5;
                    final belowHoopY = targetTopY + h * 0.35;
                    final fallProgress = progress - 1.0; // 0.0 → 1.0
                    ballY = aboveHoopY + (belowHoopY - aboveHoopY) * fallProgress;
                  }
                  final ballX = targetCenterX - ballSize / 2;
                  return Positioned(
                    left: ballX,
                    top: ballY,
                    child: Opacity(
                      opacity: _scoreOpacity.value,
                      child: Image.asset('assets/images/top.png', width: ballSize, height: ballSize),
                    ),
                  );
                },
              ),

            // Yanlış cevap: aşağıdan potanın üstüne çıkar, potadan sekip sağa düşer
            if (_isAnimating && _lastResultCorrect == false)
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  final progress = _bounceProgress.value;
                  double ballY;
                  if (progress <= 1.0) {
                    // Faz 1: orta-alttan (ballRestY) potanın üstüne yükselir
                    final aboveHoopY = targetTopY - ballSize * 1.5;
                    ballY = ballRestY + (aboveHoopY - ballRestY) * progress;
                  } else {
                    // Faz 2-3: potanın üstünden sekme ve düşme
                    final aboveHoopY = targetTopY - ballSize * 1.5;
                    final fallDistance = h * 0.5;
                    final normalizedFall = (progress - 1.0) / 2.0;
                    ballY = aboveHoopY + fallDistance * normalizedFall;
                  }
                  final ballX = targetCenterX - ballSize / 2 + _bounceXAnimation.value * w * 0.15;
                  return Positioned(
                    left: ballX,
                    top: ballY,
                    child: Transform.rotate(
                      angle: _bounceRotation.value,
                      child: Image.asset('assets/images/top.png', width: ballSize, height: ballSize),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _extractQuestionText(String text) {
    if (text.contains(' | ')) {
      return text.split(' | ').sublist(1).join(' | ').trim();
    }
    return text;
  }
}

// Custom Painter to draw a clean speech bubble with a tail pointing down-left for questions
class QuestionBubblePainter extends CustomPainter {
  final Color color;

  QuestionBubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = 12.0;

    // Rounded rectangle including tail at the bottom-left
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius));
    path.lineTo(size.width, size.height - 12 - radius);
    path.arcToPoint(Offset(size.width - radius, size.height - 12), radius: const Radius.circular(radius));

    // Tail at bottom-left pointing down-left
    path.lineTo(35, size.height - 12);
    path.lineTo(12, size.height);
    path.lineTo(20, size.height - 12);

    path.lineTo(radius, size.height - 12);
    path.arcToPoint(Offset(0, size.height - 12 - radius), radius: const Radius.circular(radius));
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius));
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

