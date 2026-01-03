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
    Color(0xFFEF5350),
    Color(0xFFF06292),
    Color(0xFFAB47BC),
    Color(0xFF7E57C2),
    Color(0xFF5C6BC0),
    Color(0xFF42A5F5),
    Color(0xFF29B6F6),
    Color(0xFF26C6DA),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFF9CCC65),
    Color(0xFFD4E157),
    Color(0xFFFFCA28),
    Color(0xFFFFA726),
    Color(0xFFFF7043),
    Color(0xFF8D6E63),
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
