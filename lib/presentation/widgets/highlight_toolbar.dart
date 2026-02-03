import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class HighlightToolbar extends StatelessWidget {
  final Function(Color) onColorSelected;
  final VoidCallback onAddNote;
  final VoidCallback onCancel;

  const HighlightToolbar({
    super.key,
    required this.onColorSelected,
    required this.onAddNote,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ColorButton(
            color: Colors.yellow,
            onTap: () => onColorSelected(Colors.yellow),
          ),
          _ColorButton(
            color: Colors.green,
            onTap: () => onColorSelected(Colors.green),
          ),
          _ColorButton(
            color: Colors.blue,
            onTap: () => onColorSelected(Colors.blue),
          ),
          _ColorButton(
            color: Colors.pink,
            onTap: () => onColorSelected(Colors.pink),
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showColorPicker(context),
            tooltip: AppLocalizations.of(context).moreColors,
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: onAddNote,
            tooltip: AppLocalizations.of(context).addNote,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancel,
            tooltip: AppLocalizations.of(context).cancel,
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color selectedColor = Colors.yellow;

    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.pickColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) => selectedColor = color,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onColorSelected(selectedColor);
            },
            child: Text(loc.select),
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
        ),
      ),
    );
  }
}
