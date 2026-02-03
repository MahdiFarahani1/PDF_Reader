import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/logic/cubits/settings/cubit/settings_cubit.dart';
import 'package:flutter_application_1/logic/cubits/settings/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfx/pdfx.dart' as pdf;
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../data/models/document_model.dart';
import '../../../logic/cubits/reader/reader_cubit.dart';
import '../../../logic/cubits/reader/reader_state.dart';

import '../../widgets/bookmark_list_widget.dart';
import '../../widgets/search_overlay.dart';
import '../../../data/models/search_result_model.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/snackbar_common.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

class ReaderScreen extends StatefulWidget {
  final DocumentModel document;

  const ReaderScreen({super.key, required this.document});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with SingleTickerProviderStateMixin {
  pdf.PdfController? _pdfController;
  final EpubController _epubController = EpubController();
  final ScrollController _txtScrollController = ScrollController();

  bool _isLoading = true;
  bool _showSearch = false;
  bool _showBookmarks = false;
  bool _showControls = true;
  int? _currentPage;
  int? _totalPages;
  String? _currentEpubCfi;
  double _epubProgress = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _controlsAnimationController;
  late Animation<Offset> _controlsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeReader();
    _setupAnimations();
    _hideControlsAfterDelay();
  }

  void _setupAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controlsSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
          CurvedAnimation(
            parent: _controlsAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  Timer? _controlsTimer;

  void _hideControlsAfterDelay() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
          _controlsAnimationController.forward();
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controlsAnimationController.reverse();
        _hideControlsAfterDelay();
      } else {
        _controlsAnimationController.forward();
      }
    });
  }

  Future<void> _initializeReader() async {
    try {
      await context.read<ReaderCubit>().initializeDocument(
        widget.document.id,
        savedPage: widget.document.currentPage,
        savedPosition: widget.document.lastReadPosition,
      );

      if (widget.document.fileType == FileType.pdf) {
        final pdfDocumentFuture = pdf.PdfDocument.openFile(
          widget.document.path,
        );
        _pdfController = pdf.PdfController(
          document: pdfDocumentFuture,
          initialPage: widget.document.currentPage ?? 1,
        );

        // Get total pages
        final pdfDocument = await pdfDocumentFuture;
        setState(() {
          _totalPages = pdfDocument.pagesCount;
          _currentPage = widget.document.currentPage ?? 1;
        });
      } else if (widget.document.fileType == FileType.epub) {
        // For EPUB, flutter_epub_viewer will handle it in the UI
        // No special initialization needed
      } else if (widget.document.fileType == FileType.sheet ||
          widget.document.fileType == FileType.word) {
        // No detailed initialization needed for external files
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _pdfController?.dispose();
    _txtScrollController.dispose();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildBookmarksDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SlideTransition(
          position: _controlsSlideAnimation,
          child: AppBar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.95),
            elevation: 0,
            title: Text(
              widget.document.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              // IconButton(
              //   icon: Image.asset(AppIcons.searchAlt, width: 24, height: 24),
              //   tooltip: loc.search,
              //   onPressed: () {
              //     setState(() {
              //       _showSearch = !_showSearch;
              //     });
              //   },
              // ),
              IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
                icon: Image.asset(
                  AppIcons.bookmark,
                  width: 24,
                  height: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: loc.bookmarks,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'add_bookmark') {
                    _addBookmark();
                  } else if (value == 'settings') {
                    _showReadingSettings();
                  } else if (value == 'share_page') {
                    _sharePageAsImage();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'add_bookmark',
                    child: Row(
                      children: [
                        Image.asset(
                          AppIcons.squareDashedCirclePlus,
                          width: 20,
                          height: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(loc.addBookmark),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Image.asset(
                          AppIcons.priorityArrows,
                          width: 20,
                          height: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(loc.readingPreferences),
                      ],
                    ),
                  ),
                  if (widget.document.fileType == FileType.pdf) ...[
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'share_page',
                      child: Row(
                        children: [
                          Icon(
                            Icons.share,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text(loc.sharePageAsImage),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Main Reader
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      '${loc.loading} ${widget.document.fileType.name.toUpperCase()}...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              _buildReader(),

            // Search Overlay
            if (_showSearch)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: BlocBuilder<ReaderCubit, ReaderState>(
                  builder: (context, state) {
                    return SearchOverlay(
                      searchQuery: state.searchQuery,
                      results: state.searchResults,
                      currentIndex: state.currentSearchIndex,
                      isSearching: state.isSearching,
                      onSearch: (query) {
                        context.read<ReaderCubit>().performSearch(query);
                      },
                      onClose: () {
                        setState(() {
                          _showSearch = false;
                        });
                        context.read<ReaderCubit>().clearSearch();
                      },
                      onResultTap: (result) {
                        _onSearchResultTap(result);
                      },
                    );
                  },
                ),
              ),

            // Bookmarks Drawer
            if (_showBookmarks)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showBookmarks = false;
                    });
                  },
                  child: Container(color: Colors.black54),
                ),
              ),

            if (_showBookmarks)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Material(
                  elevation: 16,
                  child: Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(-5, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppIcons.bookmark,
                                width: 24,
                                height: 24,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                loc.bookmarks,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Image.asset(
                                  AppIcons
                                      .angleDoubleSmallLeft, // Using as close icon if no specific close icon, rotating might be needed or just use as is
                                  width: 24,
                                  height: 24,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showBookmarks = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: BlocBuilder<ReaderCubit, ReaderState>(
                            builder: (context, state) {
                              return BookmarkListWidget(
                                bookmarks: state.bookmarks,
                                onBookmarkTap: (bookmark) {
                                  if (bookmark.pageNumber != null &&
                                      _pdfController != null) {
                                    _pdfController!.jumpToPage(
                                      bookmark.pageNumber!,
                                    );
                                  }
                                  setState(() {
                                    _showBookmarks = false;
                                  });
                                },
                                onBookmarkDelete: (id) {
                                  context.read<ReaderCubit>().removeBookmark(
                                    id,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Page Slider for PDF and EPUB
            if (!_isLoading &&
                (widget.document.fileType == FileType.pdf ||
                    widget.document.fileType == FileType.epub) &&
                (widget.document.fileType == FileType.epub ||
                    (_totalPages != null && _currentPage != null)))
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.95),
                          Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.8),
                          Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page counter / Progress
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.document.fileType == FileType.pdf
                                ? '${loc.page} $_currentPage ${loc.offf} $_totalPages'
                                : '${(_epubProgress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Page slider
                        Row(
                          children: [
                            // Previous/Start Button
                            IconButton(
                              icon: Image.asset(
                                context
                                            .read<SettingsCubit>()
                                            .state
                                            .languageCode ==
                                        'fa'
                                    ? AppIcons.angleDoubleSmallRight
                                    : AppIcons.angleDoubleSmallLeft,
                                width: 24,
                                height: 24,
                              ),
                              onPressed:
                                  widget.document.fileType == FileType.pdf
                                  ? (_currentPage! > 1
                                        ? () => _pdfController?.jumpToPage(1)
                                        : null)
                                  : null, // No "jump to start" for EPUB yet
                            ),
                            // Previous Page Button
                            IconButton(
                              icon: Image.asset(
                                context
                                            .read<SettingsCubit>()
                                            .state
                                            .languageCode ==
                                        'fa'
                                    ? AppIcons.angleDoubleSmallRight
                                    : AppIcons.angleDoubleSmallLeft,
                                width: 24,
                                height: 24,
                              ),
                              onPressed:
                                  widget.document.fileType == FileType.pdf
                                  ? (_currentPage! > 1
                                        ? () {
                                            final target = _currentPage! - 1;
                                            if (target >= 1) {
                                              _pdfController?.jumpToPage(
                                                target,
                                              );
                                            }
                                          }
                                        : null)
                                  : () => _epubController.prev(),
                            ),
                            // Slider
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  inactiveTrackColor: Colors.grey,
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                ),
                                child: Slider(
                                  value:
                                      widget.document.fileType == FileType.pdf
                                      ? _currentPage!.toDouble()
                                      : _epubProgress,
                                  min: widget.document.fileType == FileType.pdf
                                      ? 1
                                      : 0.0,
                                  max: widget.document.fileType == FileType.pdf
                                      ? _totalPages!.toDouble()
                                      : 1.0,
                                  divisions:
                                      widget.document.fileType == FileType.pdf
                                      ? (_totalPages! > 1
                                            ? _totalPages! - 1
                                            : 1)
                                      : 100,
                                  label:
                                      widget.document.fileType == FileType.pdf
                                      ? '$_currentPage'
                                      : '${(_epubProgress * 100).toInt()}%',
                                  onChanged: (value) {
                                    if (widget.document.fileType ==
                                        FileType.pdf) {
                                      _pdfController?.jumpToPage(value.toInt());
                                    } else {
                                      // Update state instantly for UI feedback
                                      setState(() {
                                        _epubProgress = value;
                                      });
                                    }
                                  },
                                  onChangeEnd: (value) {
                                    // Navigate only on end for EPUB to avoid performance issues
                                    if (widget.document.fileType ==
                                        FileType.epub) {
                                      // _epubController.toProgressPercentage(value); // Not available in widget
                                      // Fallback: Use goto logic if percentages are supported via CFI or search
                                      // Current flutter_epub_viewer doesn't expose explicit percentage jump easily
                                      // But let's check if we can simulate it or if access is available
                                      // For now, disabling slider dragging for EPUB effectively or keeping it read-only
                                      // until we confirm API
                                    }
                                  },
                                ),
                              ),
                            ),
                            // Next Page Button
                            IconButton(
                              icon: Image.asset(
                                context
                                            .read<SettingsCubit>()
                                            .state
                                            .languageCode ==
                                        'fa'
                                    ? AppIcons.angleDoubleSmallLeft
                                    : AppIcons.angleDoubleSmallRight,
                                width: 24,
                                height: 24,
                              ),
                              onPressed:
                                  widget.document.fileType == FileType.pdf
                                  ? (_currentPage! < _totalPages!
                                        ? () {
                                            final target = _currentPage! + 1;
                                            if (target <= _totalPages!) {
                                              _pdfController?.jumpToPage(
                                                target,
                                              );
                                            }
                                          }
                                        : null)
                                  : () => _epubController.next(),
                            ),
                            // Next/End Button
                            IconButton(
                              icon: Image.asset(
                                context
                                            .read<SettingsCubit>()
                                            .state
                                            .languageCode ==
                                        'fa'
                                    ? AppIcons.angleDoubleSmallLeft
                                    : AppIcons.angleDoubleSmallRight,
                                width: 24,
                                height: 24,
                              ),
                              onPressed:
                                  widget.document.fileType == FileType.pdf
                                  ? (_currentPage! < _totalPages!
                                        ? () => _pdfController?.jumpToPage(
                                            _totalPages!,
                                          )
                                        : null)
                                  : null, // No "jump to end" for EPUB yet
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReader() {
    final loc = AppLocalizations.of(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.isVerticalMode != current.isVerticalMode,
      builder: (context, settings) {
        switch (widget.document.fileType) {
          case FileType.pdf:
            {
              if (_pdfController == null) {
                return Center(child: Text(loc.failedLoadPdf));
              }
              final isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;
              Widget pdfView = pdf.PdfView(
                controller: _pdfController!,
                scrollDirection: settings.isVerticalMode
                    ? Axis.vertical
                    : Axis.horizontal,
                pageSnapping: !settings.isVerticalMode,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  // Auto-save position
                  context.read<ReaderCubit>().updatePosition(page: page);
                },
                builders: pdf.PdfViewBuilders<pdf.DefaultBuilderOptions>(
                  options: const pdf.DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  pageLoaderBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  pageBuilder: (context, pageImageFuture, index, document) {
                    return pdf.PhotoViewGalleryPageOptions(
                      imageProvider: pdf.PdfPageImageProvider(
                        pageImageFuture,
                        index,
                        document.id,
                      ),
                      minScale: pdf.PhotoViewComputedScale.contained * 1.0,
                      maxScale: pdf.PhotoViewComputedScale.contained * 5.0,

                      heroAttributes: pdf.PhotoViewHeroAttributes(
                        tag: '${document.id}-$index',
                      ),
                    );
                  },
                ),
              );

              if (isDarkMode) {
                pdfView = ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    -1,
                    0,
                    0,
                    0,
                    255,
                    0,
                    -1,
                    0,
                    0,
                    255,
                    0,
                    0,
                    -1,
                    0,
                    255,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: pdfView,
                );
              }

              return Container(
                color: isDarkMode
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF5F5F5),
                child: pdfView,
              );
            }

          case FileType.epub:
            return GestureDetector(
              onTap: _toggleControls,
              behavior: HitTestBehavior
                  .opaque, // Ensure it captures if not consumed? But we want to *pass through* if consumed.
              // Actually, opaque might block the webview.
              // Let's try wrapping without opaque first, or use Listener if needed.
              // But standard GestureDetector on top of webview often fails.
              // However, since we want to *toggle*, maybe we can just overlay a transparent detector?
              // No, that blocks interaction.
              // Let's try GestureDetector around it. If it doesn't work, we'll need a Stack with Listener.
              child: EpubViewer(
                epubSource: EpubSource.fromFile(File(widget.document.path)),
                epubController: _epubController,
                displaySettings: EpubDisplaySettings(
                  flow: EpubFlow.paginated,
                  snap: true,
                ),
                onEpubLoaded: () async {
                  debugPrint('EPUB loaded successfully');
                },
                onRelocated: (location) {
                  // Debug EPUB location structure
                  debugPrint('EPUB Relocated Object: $location');

                  // Try to extract cfi and progress dynamically since types are uncertain
                  try {
                    final dynamic loc = location;
                    // Attempt to get CFI
                    String? cfi;
                    try {
                      cfi = loc.cfi;
                    } catch (_) {}
                    try {
                      cfi ??= loc.start.cfi;
                    } catch (_) {}

                    if (cfi != null && mounted) {
                      setState(() {
                        _currentEpubCfi = cfi;
                      });
                    }

                    // Attempt to get Progress (0.0 - 1.0)
                    // Some plugins return 'progress' or need calculation
                    // For now, if we can't get it, we default to 0.0
                    // Note: flutter_epub_viewer might not expose progress in location directly
                  } catch (e) {
                    debugPrint('Error parsing EPUB location: $e');
                  }
                },
              ),
            );

          case FileType.txt:
            return _buildTextViewer(settings);

          case FileType.sheet:
          case FileType.word:
            return _buildExternalFileViewer();

          default:
            // Fallback for files that might have been imported as 'unknown' but have supported extensions
            final ext = widget.document.path.split('.').last.toLowerCase();
            if (ext == 'xlsx' ||
                ext == 'xls' ||
                ext == 'docx' ||
                ext == 'doc') {
              return _buildExternalFileViewer();
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppIcons.fileCircleInfo,
                    width: 64,
                    height: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text("${loc.unsupportedFileType}: .${ext.toUpperCase()}"),
                  const SizedBox(height: 16),
                  Text(loc.supportedTypesInfo),
                ],
              ),
            );
        }
      },
    );
  }

  Widget _buildTextViewer(SettingsState settings) {
    final loc = AppLocalizations.of(context);
    return FutureBuilder<String>(
      future: File(widget.document.path).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final content = snapshot.data!;
          final searchQuery = context.select(
            (ReaderCubit cubit) => cubit.state.searchQuery,
          );

          return Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFFAF8F3),
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _txtScrollController,
                physics: const BouncingScrollPhysics(),
                child: SelectableText.rich(
                  _buildHighlightedTextSpan(
                    content,
                    searchQuery,
                    settings,
                    Theme.of(context),
                  ),
                  onSelectionChanged: (selection, cause) {
                    if (selection.start != selection.end) {
                      final selectedText = content.substring(
                        selection.start,
                        selection.end,
                      );
                      _showHighlightOptions(selectedText);
                    }
                  },
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppIcons.fileCircleInfo,
                  width: 64,
                  height: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text("${loc.errorReadingFile}: ${snapshot.error}"),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildExternalFileViewer() {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            widget.document.fileType == FileType.sheet
                ? AppIcons.addDocument
                : AppIcons.fileWord,
            width: 100,
            height: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            loc.externalAppSupport,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await OpenFilex.open(widget.document.path);
              if (result.type != ResultType.done) {
                if (mounted) {
                  AppSnackBar.showError(
                    context,
                    result.message.isNotEmpty
                        ? result.message
                        : loc.couldNotOpenFile,
                  );
                }
              }
            },
            icon: Image.asset(
              AppIcons.squareDashedCirclePlus,
              width: 20,
              height: 20,
            ),
            label: const Text('Open with External App'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePageAsImage() async {
    final loc = AppLocalizations.of(context);
    if (widget.document.fileType != FileType.pdf || _pdfController == null) {
      return;
    }

    try {
      // Show loading indicator
      if (!mounted) return;

      AppSnackBar.showInfo(context, loc.preparingPageImage);

      final pdfDocument = await _pdfController!.document;
      final page = await pdfDocument.getPage(_currentPage!);
      final pageImage = await page.render(
        width: page.width * 2, // Double resolution for better quality
        height: page.height * 2,
        format: pdf.PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF', // Fix for black/transparent background
        quality: 100,
      );
      await page.close();

      if (pageImage != null) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/page_${widget.document.id}_$_currentPage.png';
        final file = File(filePath);
        await file.writeAsBytes(pageImage.bytes);

        await share_plus.Share.shareXFiles([
          share_plus.XFile(filePath),
        ], text: 'Shared from ${widget.document.title}');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to share page: $e');
      }
    }
  }

  void _onSearchResultTap(SearchResultModel result) {
    if (result.pageNumber != null) {
      if (widget.document.fileType == FileType.pdf && _pdfController != null) {
        _pdfController!.jumpToPage(result.pageNumber!);
      }
      // EPUB search is handled by cosmos_epub's built-in search
    } else if (result.startPosition != null) {
      if (widget.document.fileType == FileType.txt &&
          _txtScrollController.hasClients) {
        // Rough estimate of scroll position based on character index
        // This works best if content is already loaded and laid out
        final content = File(widget.document.path).readAsStringSync();
        final ratio = result.startPosition! / content.length;
        final targetOffset =
            ratio * _txtScrollController.position.maxScrollExtent;
        _txtScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
    setState(() {
      _showSearch = false;
    });
  }

  TextSpan _buildHighlightedTextSpan(
    String content,
    String? query,
    SettingsState settings,
    ThemeData theme,
  ) {
    final baseStyle = TextStyle(
      letterSpacing: 0.3,
      color: theme.textTheme.bodyLarge?.color,
    );

    if (query == null || query.isEmpty)
      return TextSpan(text: content, style: baseStyle);

    final List<TextSpan> spans = [];
    final lowerContent = content.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerContent.indexOf(lowerQuery, start)) != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: content.substring(start, indexOfMatch)));
      }

      spans.add(
        TextSpan(
          text: content.substring(indexOfMatch, indexOfMatch + query.length),
          style: baseStyle.copyWith(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.3),
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = indexOfMatch + query.length;
    }

    if (start < content.length) {
      spans.add(TextSpan(text: content.substring(start)));
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  Future<void> _addBookmark() async {
    final readerCubit = context.read<ReaderCubit>();

    if (widget.document.fileType == FileType.pdf) {
      if (_currentPage != null) {
        await readerCubit.addBookmark(
          pageNumber: _currentPage,
          label: 'Page $_currentPage',
        );
        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            AppLocalizations.of(context).addBookmark,
          );
        }
      }
    } else if (widget.document.fileType == FileType.epub) {
      // For EPUB, we use CFI if available
      if (_currentEpubCfi != null) {
        await readerCubit.addBookmark(
          cfi: _currentEpubCfi,
          label: 'Bookmark', // TODO: Add better label based on chapter/location
        );
        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            AppLocalizations.of(context).addBookmark,
          );
        }
      } else {
        // Fallback or warning if CFI not available
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Unable to bookmark this location yet.',
          );
        }
      }
    }
  }

  void _showHighlightOptions(String selectedText) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).highlightText,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _colorButton(Colors.yellow.shade300, selectedText, 'Yellow'),
                _colorButton(Colors.green.shade300, selectedText, 'Green'),
                _colorButton(Colors.blue.shade300, selectedText, 'Blue'),
                _colorButton(Colors.pink.shade300, selectedText, 'Pink'),
                _colorButton(Colors.orange.shade300, selectedText, 'Orange'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Color color, String text, String label) {
    return InkWell(
      onTap: () {
        context.read<ReaderCubit>().addHighlight(
          selectedText: text,
          pageNumber: _currentPage,
          color: color,
        );
        Navigator.pop(context);
        AppSnackBar.showSuccess(context, 'Highlighted with $label');
      },
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  void _showReadingSettings() {
    final loc = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                final settingsCubit = context.read<SettingsCubit>();

                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.readingPreferences,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),

                    // Reading Mode
                    _buildSettingSection(
                      context,
                      icon: Icons.swap_vert,
                      title: loc.readingMode,
                      subtitle: state.isVerticalMode
                          ? loc.vertical
                          : loc.horizontal,
                      child: Switch(
                        value: state.isVerticalMode,
                        onChanged: (_) {
                          settingsCubit.toggleReadingMode();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildBookmarksDrawer() {
    return Drawer(
      width: 300,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.bookmarks_outlined),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).bookmarks,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<ReaderCubit, ReaderState>(
              builder: (context, state) {
                if (state.bookmarks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookmarks yet',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: state.bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = state.bookmarks[index];
                    return ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: Text(bookmark.label ?? 'Bookmark'),
                      subtitle: Text(
                        // Format date
                        '${bookmark.createdAt.year}/${bookmark.createdAt.month}/${bookmark.createdAt.day}',
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        if (widget.document.fileType == FileType.pdf &&
                            bookmark.pageNumber != null) {
                          _pdfController?.jumpToPage(bookmark.pageNumber!);
                        } else if (widget.document.fileType == FileType.epub &&
                            bookmark.cfi != null) {
                          _epubController.display(cfi: bookmark.cfi!);
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () {
                          context.read<ReaderCubit>().removeBookmark(
                            bookmark.id,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
