import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../providers/quiz_provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/test/test_question_widget.dart';
import '../widgets/ordering/ordering_question_widget.dart';
import '../widgets/ordering/list_ordering_question_widget.dart';
import '../widgets/true_false/true_false_question_widget.dart';
import '../widgets/module_progress_bar.dart';
import '../widgets/horizontal_road_animation.dart';
import '../widgets/module_three_road_animation.dart';
import '../../data/models/option.dart';
import '../../data/models/ordering_item.dart';
import '../../data/database/database_helper.dart';
import '../../core/services/sound_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  bool _showCorrectFeedback = false;
  bool _showExplanation = false;
  String? _explanationText;

  // Modül ilerleme bar durumu
  bool _showProgressBar = false;
  int _progressBarTotal = 0;
  int _progressBarCompleted = 0;

  // Modül 3 yol animasyonu durumu
  bool _showModuleThreeRoadAnimation = false;
  int _moduleThreeRoadTotal = 0;
  int _moduleThreeRoadCompleted = 0;

  // Modül geçiş yol animasyonu
  bool _showRoadAnimation = false;
  int _totalModules = 0;
  int _roadFromNodeIndex = 0;

  // Yıldız animasyonu
  late AnimationController _starController;

  // Doğru cevap mesajları
  final List<String> _successMessages = [
    'HARİKA! 🎉',
    'MÜKEMMEL! ⭐',
    'SÜPER! 🌟',
    'BRAVO! 👏',
    'DOĞRU! ✅',
  ];

  // Her soru için DB'den çekilen veriler
  List<Option> _currentOptions = [];
  List<OrderingItem> _currentOrderingItems = [];

  // Soru widget'ını sıfırlamak için key
  Key _questionKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Ses servisini başlat
    SoundService.instance.init();
  }

  @override
  void dispose() {
    _starController.dispose();
    SoundService.instance.pauseBackground();
    super.dispose();
  }

  Future<void> _loadQuestionData(int questionId, String type, {bool isFirstLoad = false}) async {
    final db = await DatabaseHelper.instance.database;

    if (type == 'test') {
      final optionMaps =
          await db.query('options', where: 'question_id = ?', whereArgs: [questionId]);
      if (mounted) {
        setState(() {
          _currentOptions = optionMaps.map((m) => Option.fromMap(m)).toList();
        });
      }
      // Test sorusu yüklendi, arka plan müziğini devam ettir
      if (isFirstLoad) {
        await Future.delayed(const Duration(milliseconds: 500));
        SoundService.instance.playBackground(force: true);
      } else {
        SoundService.instance.playBackground();
      }
    } else if (type == 'ordering') {
      final orderingMaps = await db.query('ordering_items',
          where: 'question_id = ?', whereArgs: [questionId]);
      if (mounted) {
        setState(() {
          _currentOrderingItems =
              orderingMaps.map((m) => OrderingItem.fromMap(m)).toList();
        });
      }
      // Sıralama sorusu yüklendi, arka plan müziğini devam ettir
      if (isFirstLoad) {
        await Future.delayed(const Duration(milliseconds: 500));
        SoundService.instance.playBackground(force: true);
      } else {
        SoundService.instance.playBackground();
      }
    }
  }

  void _submitAnswer(bool correct) {
    // Onayla butonuna basıldığı an arka plan müziğini duraklat
    SoundService.instance.pauseBackground();

    final state = ref.read(quizProvider);
    final currentQuestion = state.questions[state.currentIndex];

    if (correct) {
      // Doğru cevap → feedback göster, sonra sonraki soruya geç
      SoundService.instance.playCorrect();
      _starController.repeat();
      setState(() {
        _showCorrectFeedback = true;
      });
    } else {
      // Yanlış cevap → açıklama göster, sonraki soruya geçme
      SoundService.instance.playWrong();
      setState(() {
        _showExplanation = true;
        _explanationText = currentQuestion.explanation ?? 'Cevabın yanlış. Tekrar dene!';
      });
      // Yanlış sayısını artırmıyoruz — doğru yapana kadar sayılmayacak
    }
  }

  void _dismissExplanation() {
    // Açıklamayı kapat, kullanıcı tekrar denesin
    setState(() {
      _showExplanation = false;
      _explanationText = null;
      _questionKey = UniqueKey(); // Widget'ı sıfırla
    });
    // Tamam butonuna basınca arka plan müziğini devam ettir
    SoundService.instance.playBackground();
  }

  /// Mevcut sorunun modülündeki pozisyonunu ve toplam soru sayısını hesaplar.
  /// Dönen değer: (modüldeki tamamlanan soru sayısı, modüldeki toplam soru sayısı)
  (int, int) _calculateModuleProgress() {
    final state = ref.read(quizProvider);
    final currentQuestion = state.questions[state.currentIndex];
    final currentGroupId = currentQuestion.quizGroupId;

    // Aynı modüldeki tüm soruları bul
    final moduleQuestions = state.questions
        .where((q) => q.quizGroupId == currentGroupId)
        .toList();

    final totalInModule = moduleQuestions.length;

    // Bu modüldeki kaçıncı soruda olduğumuzu bul
    int indexInModule = 0;
    for (int i = 0; i < state.questions.length; i++) {
      if (state.questions[i].quizGroupId == currentGroupId) {
        if (i == state.currentIndex) break;
        indexInModule++;
      }
    }

    // Tamamlanan = mevcut index + 1 (yeni doğru yapılan dahil)
    final completedInModule = indexInModule + 1;

    return (completedInModule, totalInModule);
  }

  void _goToNextQuestion() {
    _starController.stop();
    _starController.reset();

    // Modül ilerlemesini hesapla
    final (completed, total) = _calculateModuleProgress();
    final state = ref.read(quizProvider);
    final currentQuestion = state.questions[state.currentIndex];

    if (currentQuestion.quizGroupId == 3) {
      setState(() {
        _showCorrectFeedback = false;
        _showModuleThreeRoadAnimation = true;
        _moduleThreeRoadTotal = total;
        _moduleThreeRoadCompleted = completed;
      });
    } else {
      setState(() {
        _showCorrectFeedback = false;
        _showProgressBar = true;
        _progressBarTotal = total;
        _progressBarCompleted = completed;
      });
    }
  }

  /// Progress bar animasyonu tamamlandığında çağrılır.
  void _onProgressBarComplete() {
    if (!mounted) return;

    if (_progressBarCompleted == _progressBarTotal) {
      // Modül bitti. 
      final state = ref.read(quizProvider);
      final currentQuestion = state.questions[state.currentIndex];
      final moduleIds = state.questions.map((q) => q.quizGroupId).toSet().toList();
      final totalModules = moduleIds.length;
      final currentModuleIndex = moduleIds.indexOf(currentQuestion.quizGroupId);

      // Eğer son modül değilse yolu göster
      if (currentModuleIndex < totalModules - 1) {
        setState(() {
          _showProgressBar = false;
          _showRoadAnimation = true;
          _totalModules = totalModules;
          _roadFromNodeIndex = currentModuleIndex; // Başlangıç noktası yok, Modül 1 = 0. Nokta.
        });
        return; // nextQuestion'ı road animasyonu bitince çağıracağız
      }
    }

    setState(() {
      _showProgressBar = false;
      _currentOptions = [];
      _currentOrderingItems = [];
      _questionKey = UniqueKey();
    });
    ref.read(quizProvider.notifier).nextQuestion(true);
  }

  void _onModuleThreeRoadAnimationComplete() {
    if (!mounted) return;

    if (_moduleThreeRoadCompleted == _moduleThreeRoadTotal) {
      // Modül bitti. 
      final state = ref.read(quizProvider);
      final currentQuestion = state.questions[state.currentIndex];
      final moduleIds = state.questions.map((q) => q.quizGroupId).toSet().toList();
      final totalModules = moduleIds.length;
      final currentModuleIndex = moduleIds.indexOf(currentQuestion.quizGroupId);

      // Eğer son modül değilse yolu göster
      if (currentModuleIndex < totalModules - 1) {
        setState(() {
          _showModuleThreeRoadAnimation = false;
          _showRoadAnimation = true;
          _totalModules = totalModules;
          _roadFromNodeIndex = currentModuleIndex;
        });
        return;
      }
    }

    setState(() {
      _showModuleThreeRoadAnimation = false;
      _currentOptions = [];
      _currentOrderingItems = [];
      _questionKey = UniqueKey();
    });
    ref.read(quizProvider.notifier).nextQuestion(true);
  }

  void _onRoadAnimationComplete() {
    if (!mounted) return;
    setState(() {
      _showRoadAnimation = false;
      _currentOptions = [];
      _currentOrderingItems = [];
      _questionKey = UniqueKey();
    });
    ref.read(quizProvider.notifier).nextQuestion(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    if (state.isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (state.currentIndex >= state.questions.length) {
      SoundService.instance.pauseBackground();
      return _buildResultScreen(state);
    }

    final currentQuestion = state.questions[state.currentIndex];
    final moduleTitle = state.moduleTitles[currentQuestion.quizGroupId] ?? '';

    // Soru değiştiğinde veri yükle
    _loadQuestionDataIfNeeded(currentQuestion.id, currentQuestion.type);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modül ${currentQuestion.quizGroupId} • Soru ${state.currentIndex + 1}/${state.questions.length}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          // TEST AMAÇLI İLERİ BUTONU
          TextButton(
            onPressed: () {
              setState(() {
                _currentOptions = [];
                _currentOrderingItems = [];
                _questionKey = UniqueKey();
              });
              ref.read(quizProvider.notifier).nextQuestion(false);
            },
            child: const Text(
              'İleri',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.correct.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✅ ${state.correctCount}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
        backgroundColor: AppColors.appBar,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Ana içerik
          if (currentQuestion.type == 'true_false')
            // True/False: tam ekran layout (widget kendi soru metnini gösteriyor)
            Positioned.fill(
              child: _buildQuestionContent(currentQuestion, key: _questionKey),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 400 ? 12 : 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Soru metni + Robot Stack
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Question speech bubble
                      Padding(
                        padding: const EdgeInsets.only(left: 55.0, bottom: 15.0),
                        child: CustomPaint(
                          painter: QuestionBubblePainter(color: AppColors.cardBg),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              bottom: 28.0, // extra padding for the tail
                            ),
                            child: _buildQuestionText(currentQuestion.questionText, screenWidth, moduleTitle),
                          ),
                        ),
                      ),
                      // 2. Thinking Robot image at bottom-left
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/3.png',
                          width: 75,
                          height: 75,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Soru içeriği
                  Expanded(
                    child: _buildQuestionContent(
                        currentQuestion, key: _questionKey),
                  ),
                ],
              ),
            ),

          // Doğru cevap feedback overlay
          if (_showCorrectFeedback) _buildCorrectFeedbackOverlay(),

          // Modül ilerleme bar overlay
          if (_showProgressBar)
            Positioned.fill(
              child: ModuleProgressBar(
                totalQuestions: _progressBarTotal,
                completedCount: _progressBarCompleted,
                onAnimationComplete: _onProgressBarComplete,
              ),
            ),

          // Modül 3 yol ve araba animasyonu overlay
          if (_showModuleThreeRoadAnimation)
            Positioned.fill(
              child: ModuleThreeRoadAnimation(
                totalQuestions: _moduleThreeRoadTotal,
                completedCount: _moduleThreeRoadCompleted,
                onComplete: _onModuleThreeRoadAnimationComplete,
              ),
            ),

          // Modül geçiş yatay yol animasyonu overlay
          if (_showRoadAnimation)
            Positioned.fill(
              child: HorizontalRoadAnimation(
                totalModules: _totalModules,
                fromNodeIndex: _roadFromNodeIndex,
                onComplete: _onRoadAnimationComplete,
              ),
            ),

          // Yanlış cevap açıklama overlay
          if (_showExplanation) _buildExplanationOverlay(),
        ],
      ),
    );
  }

  Widget _buildQuestionText(String text, double screenWidth, String moduleTitle) {
    String category;
    String question;

    if (text.contains(' | ')) {
      final parts = text.split(' | ');
      category = parts[0].trim();
      question = parts.sublist(1).join(' | ').trim();
    } else {
      category = moduleTitle;
      question = text;
    }

    return Column(
      children: [
        if (category.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: screenWidth < 400 ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (category.isNotEmpty) const SizedBox(height: 12),
        Text(
          question,
          style: TextStyle(
            fontSize: screenWidth < 400 ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int? _lastLoadedQuestionId;

  void _loadQuestionDataIfNeeded(int questionId, String type) {
    if (_lastLoadedQuestionId != questionId) {
      bool isFirstLoad = _lastLoadedQuestionId == null;
      _lastLoadedQuestionId = questionId;
      if (type == 'true_false') {
        // True/False sorusunun DB bağımlılığı olmadığı için direkt gösterilir, müzik hemen devam eder
        _loadQuestionData(questionId, type, isFirstLoad: isFirstLoad);
        if (isFirstLoad) {
          Future.delayed(const Duration(milliseconds: 500), () {
            SoundService.instance.playBackground(force: true);
          });
        } else {
          SoundService.instance.playBackground();
        }
      } else {
        _loadQuestionData(questionId, type, isFirstLoad: isFirstLoad);
      }
    }
  }

  Widget _buildQuestionContent(dynamic question, {Key? key}) {
    if (question.type == 'test') {
      if (_currentOptions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return TestQuestionWidget(
        key: key,
        options: _currentOptions,
        onAnswerSelected: _submitAnswer,
      );
    } else if (question.type == 'ordering') {
      if (_currentOrderingItems.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (question.quizGroupId == 4) {
        return ListOrderingQuestionWidget(
          key: key,
          items: _currentOrderingItems,
          onAnswerSelected: _submitAnswer,
        );
      }
      return OrderingQuestionWidget(
        key: key,
        items: _currentOrderingItems,
        onAnswerSelected: _submitAnswer,
      );
    } else if (question.type == 'true_false') {
      return TrueFalseQuestionWidget(
        key: key,
        correctAnswer: question.correctAnswerBool ?? false,
        onAnswerSelected: _submitAnswer,
        questionText: question.questionText,
      );
    }
    return const SizedBox();
  }

  Widget _buildCorrectFeedbackOverlay() {
    final message =
        _successMessages[Random().nextInt(_successMessages.length)];
    return GestureDetector(
      onTap: _goToNextQuestion,
      child: Container(
        color: Colors.black45,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Robot & Green Speech Bubble Stack
                SizedBox(
                  width: 320,
                  height: 230,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Robot image at bottom-left
                      Positioned(
                        left: 10,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/4.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Green speech bubble at top-right
                      Positioned(
                        right: 10,
                        top: 10,
                        child: CustomPaint(
                          painter: CorrectBubblePainter(color: AppColors.correct),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 16.0,
                              bottom: 31.0, // 15px tail + 16px padding
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 3 dönen yıldız
                                AnimatedBuilder(
                                  animation: _starController,
                                  builder: (context, child) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(3, (index) {
                                        final offset = index * 0.3;
                                        final rotation =
                                            (_starController.value + offset) * 2 * pi;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                          child: Transform.rotate(
                                            angle: rotation,
                                            child: Icon(
                                              Icons.star,
                                              color: AppColors.star,
                                              size: index == 1 ? 42 : 30,
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  message,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 2. Sonraki Soru button below the robot
                ElevatedButton(
                  onPressed: () {
                    SoundService.instance.playButtonClick();
                    _goToNextQuestion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.correct,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Sonraki Soru →',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 1. Crying Robot
                    Image.asset(
                      'assets/images/5.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    // 2. Red Speech Bubble
                    Expanded(
                      child: CustomPaint(
                        painter: CorrectBubblePainter(color: AppColors.wrong),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 16.0,
                            bottom: 31.0, // 15px tail + 16px padding
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline, color: Colors.white, size: 36),
                              const SizedBox(height: 8),
                              const Text(
                                'YANLIŞ!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _explanationText ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 3. TAMAM button below the robot (centered in the column)
                ElevatedButton(
                  onPressed: _dismissExplanation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.wrong,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('TAMAM',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(QuizState state) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Sonuç'), backgroundColor: AppColors.appBar),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: AppColors.star),
              const SizedBox(height: 24),
              const Text(
                'Tebrikler!',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain),
              ),
              const SizedBox(height: 16),
              Text(
                'Toplam Doğru: ${state.correctCount}/${state.questions.length}',
                style: const TextStyle(fontSize: 24, color: AppColors.textMain),
              ),
              const SizedBox(height: 40),
              // Yeniden Oyna butonu
              ElevatedButton.icon(
                onPressed: () {
                  _lastLoadedQuestionId = null;
                  _questionKey = UniqueKey();
                  _showProgressBar = false;
                  _progressBarTotal = 0;
                  _progressBarCompleted = 0;
                  _showRoadAnimation = false;
                  ref.read(quizProvider.notifier).restart();
                },
                icon: const Icon(Icons.replay, size: 28),
                label: const Text('Yeniden Oyna',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.confirmButton,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              // Çıkış Yap butonu
              OutlinedButton.icon(
                onPressed: () {
                  SystemNavigator.pop(); // Uygulamayı kapat
                },
                icon: const Icon(Icons.exit_to_app, size: 28),
                label: const Text('Çıkış Yap',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMain,
                  minimumSize: const Size(double.infinity, 60),
                  side: BorderSide(color: Colors.grey.shade400, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    const radius = 16.0;

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

// Custom Painter to draw a clean speech bubble with a tail pointing down-left for correct answers
class CorrectBubblePainter extends CustomPainter {
  final Color color;

  CorrectBubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = 20.0;

    // Rounded rectangle including tail at the bottom-left
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

    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 6.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


