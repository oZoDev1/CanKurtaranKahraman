import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/option.dart';

class TestQuestionWidget extends StatefulWidget {
  final List<Option> options;
  final Function(bool isCorrect) onAnswerSelected;

  const TestQuestionWidget({
    super.key,
    required this.options,
    required this.onAnswerSelected,
  });

  @override
  State<TestQuestionWidget> createState() => _TestQuestionWidgetState();
}

class _TestQuestionWidgetState extends State<TestQuestionWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final option = widget.options[index];
              final isSelected = _selectedIndex == index;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      option.optionText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: AppColors.textMain,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _selectedIndex == null
              ? null
              : () {
                  widget.onAnswerSelected(widget.options[_selectedIndex!].isCorrect);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.confirmButton,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('ONAYLA ✓', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
