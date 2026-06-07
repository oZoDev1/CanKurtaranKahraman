import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CanKurtaranKahraman'),
        backgroundColor: AppColors.appBar,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Center the robot and speech bubble container
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate size dynamically for responsiveness based on screen dimensions
                      final double maxBasedOnHeight = constraints.maxHeight * 0.5;
                      final double robotSize = (constraints.maxWidth * 0.65)
                          .clamp(180.0, 280.0)
                          .clamp(150.0, maxBasedOnHeight > 150.0 ? maxBasedOnHeight : 280.0);

                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // 1. The Robot Image
                          Image.asset(
                            'assets/images/robot.png',
                            width: robotSize,
                            height: robotSize,
                            fit: BoxFit.contain,
                          ),
                          // 2. The Speech Bubble, positioned slightly to the right and top
                          Positioned(
                            top: -robotSize * 0.28, // Positioned above the robot
                            right: -robotSize * 0.18, // Positioned to the right of the robot
                            child: SpeechBubble(
                              color: Colors.white,
                              child: Text(
                                'Selam!\nHadi Başlayalım',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (robotSize * 0.07).clamp(14.0, 18.0),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            // 3. Quiz'e Başla Button in the bottom-right corner of the screen
            Positioned(
              bottom: 32,
              right: 32,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text(
                  'Quiz\'e Başla!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
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

// Custom Speech Bubble Widget
class SpeechBubble extends StatelessWidget {
  final Widget child;
  final Color color;

  const SpeechBubble({
    super.key,
    required this.child,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpeechBubblePainter(color: color),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 14.0,
          bottom: 29.0, // extra padding at the bottom for the tail (15px tail + 14px padding)
        ),
        child: child,
      ),
    );
  }
}

// Custom Painter to draw a clean speech bubble with a tail pointing down-left
class SpeechBubblePainter extends CustomPainter {
  final Color color;

  SpeechBubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = 16.0;

    // We draw the outline of the bubble including the tail
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius));
    path.lineTo(size.width, size.height - 15 - radius);
    path.arcToPoint(Offset(size.width - radius, size.height - 15), radius: const Radius.circular(radius));

    // Tail at bottom-left pointing down-left
    path.lineTo(55, size.height - 15);
    path.lineTo(25, size.height);
    path.lineTo(35, size.height - 15);

    path.lineTo(radius, size.height - 15);
    path.arcToPoint(Offset(0, size.height - 15 - radius), radius: const Radius.circular(radius));
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius));
    path.close();

    // Draw shadow first
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 6.0, true);

    // Draw the bubble shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

