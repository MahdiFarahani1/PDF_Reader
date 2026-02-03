import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/app_localizations.dart';
import 'file_list_screen.dart';
import '../../../../core/utils/app_icons.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.scanDevice),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              loc.selectCat,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _CategoryCard(
                    title: loc.pdfDocument,
                    icon: AppIcons.filePdf,
                    color: const Color(0xFFEF5350),
                    extensions: const ['pdf'],
                    onTap: () =>
                        _navigateToList(context, loc.pdfDocument, ['pdf']),
                  ),
                  _CategoryCard(
                    title: loc.epubDocument,
                    icon: AppIcons.bookAlt,
                    color: const Color(0xFF42A5F5),
                    extensions: const ['epub'],
                    onTap: () =>
                        _navigateToList(context, loc.epubDocument, ['epub']),
                  ),
                  _CategoryCard(
                    title: loc.txtDocument,
                    icon: AppIcons.file,
                    color: const Color(0xFF66BB6A),
                    extensions: const ['txt'],
                    onTap: () =>
                        _navigateToList(context, loc.txtDocument, ['txt']),
                  ),
                  _CategoryCard(
                    title: loc.wordDocument,
                    icon: AppIcons.fileWord,
                    color: const Color(0xFF5C6BC0),
                    extensions: const ['doc', 'docx'],
                    onTap: () => _navigateToList(context, loc.wordDocument, [
                      'doc',
                      'docx',
                    ]),
                  ),
                  _CategoryCard(
                    title: loc.sheetDocument,
                    icon: AppIcons.addDocument,
                    color: const Color(0xFF26A69A),
                    extensions: const ['xls', 'xlsx'],
                    onTap: () => _navigateToList(context, loc.sheetDocument, [
                      'xls',
                      'xlsx',
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToList(
    BuildContext context,
    String title,
    List<String> extensions,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FileListScreen(title: title, extensions: extensions),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  final List<String> extensions;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.extensions,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 6,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.3),
                        widget.color.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Image.asset(
                    widget.icon,
                    width: 42,
                    height: 42,
                    color: widget.color,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
