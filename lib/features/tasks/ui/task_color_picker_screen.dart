import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_ext.dart';

class TaskColorPickerScreen extends StatefulWidget {
  const TaskColorPickerScreen({
    super.key,
    required this.initialColorValue,
  });

  final int initialColorValue;

  @override
  State<TaskColorPickerScreen> createState() => _TaskColorPickerScreenState();
}

class _TaskColorPickerScreenState extends State<TaskColorPickerScreen> {
  static const List<Color> _palette = [
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFF9E9E9E),
    Color(0xFFF44336),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFFEB3B),
    Color(0xFFFF9800),
    Color(0xFF795548),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFFF5F5DC),
    Color(0xFF03A9F4),
    Color(0xFF009688),
  ];

  late int _selectedColorValue;

  @override
  void initState() {
    super.initState();
    _selectedColorValue = widget.initialColorValue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskColorTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _palette.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final color = _palette[index];
                  final colorValue = color.toARGB32();
                  final isSelected = colorValue == _selectedColorValue;
                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      setState(() {
                        _selectedColorValue = colorValue;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedColorValue);
                  },
                  child: Text(l10n.confirm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
