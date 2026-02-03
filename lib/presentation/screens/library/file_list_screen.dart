import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/app_localizations.dart';
import 'package:flutter_application_1/core/widgets/custom_loading.dart';
import 'package:flutter_application_1/core/widgets/dialog_common.dart';
import 'package:flutter_application_1/core/widgets/snackbar_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import '../../../core/services/file_service.dart';
import '../../../data/models/document_model.dart';
import '../../../logic/cubits/library/library_cubit.dart';

class FileListScreen extends StatefulWidget {
  final String title;
  final List<String> extensions;

  const FileListScreen({
    super.key,
    required this.title,
    required this.extensions,
  });

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  final FileService _fileService = FileService();
  List<File> _files = [];
  List<File> _filteredFiles = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scanFiles();
    _searchController.addListener(_filterFiles);
  }

  void _filterFiles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFiles = _files
          .where((file) => p.basename(file.path).toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _scanFiles() async {
    final files = await _fileService.scanDeviceForFiles(widget.extensions);
    if (mounted) {
      setState(() {
        _files = files;
        _filteredFiles = files;
        _isLoading = false;
      });
    }
  }

  Future<void> _importFile(File file) async {
    final loc = AppLocalizations.of(context);

    try {
      AppDialog.showLoadingDialog(context, message: loc.importingFile);

      final filePath = file.path;
      final fileName = p.basename(filePath);
      final fileExtension = p
          .extension(filePath)
          .toLowerCase()
          .replaceFirst('.', '');

      FileType fileType;
      switch (fileExtension) {
        case 'pdf':
          fileType = FileType.pdf;
          break;
        case 'epub':
          fileType = FileType.epub;
          break;
        case 'txt':
          fileType = FileType.txt;
          break;
        case 'doc':
        case 'docx':
          fileType = FileType.word;
          break;
        case 'xls':
        case 'xlsx':
          fileType = FileType.sheet;
          break;
        default:
          fileType = FileType.unknown;
      }

      final copiedPath = await _fileService.copyFileToAppDirectory(filePath);
      final fileSize = await File(copiedPath).length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      if (mounted) {
        await context.read<LibraryCubit>().addDocument(
          copiedPath,
          fileName,
          fileType,
          fileSizeInMB,
        );

        Navigator.pop(context);
        AppSnackBar.showSuccess(context, '${loc.imported} $fileName');
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.showError(context, '${loc.errorImporting}: $e');
      }
    }
  }

  String _getFileIcon(String path) {
    final ext = p.extension(path).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'assets/icons/file-pdf.png';
      case '.txt':
        return 'assets/icons/document.png';
      case '.doc':
      case '.docx':
        return 'assets/icons/file-word.png';
      case '.xls':
      case '.xlsx':
        return 'assets/icons/file.png';
      case '.epub':
        return 'assets/icons/book-alt.png';
      default:
        return 'assets/icons/file.png';
    }
  }

  Color _getFileColor(String path) {
    final ext = p.extension(path).toLowerCase();
    switch (ext) {
      case '.pdf':
        return Colors.red;
      case '.txt':
        return Colors.green;
      case '.doc':
      case '.docx':
        return Colors.deepPurple;
      case '.xls':
      case '.xlsx':
        return Colors.lightGreen.shade800;
      case '.epub':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: _isLoading
          ? Center(child: CustomLoading())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: Text(widget.title),
                  bottom: AppBar(
                    automaticallyImplyLeading: false,
                    title: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: loc.searchFilesHint,
                          prefix: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Image.asset(
                              'assets/icons/search-alt.png',
                              width: 30,
                              height: 30,
                            ),
                          ),

                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(0),
                        ),
                      ),
                    ),
                  ),
                ),
                _filteredFiles.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: Text(
                                  loc.noFilesFound,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: Text(
                                  loc.noFilesFoundDesc,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[500]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final file = _filteredFiles[index];
                          return ListTile(
                            leading: Image.asset(
                              _getFileIcon(file.path),
                              width: 25,
                              height: 25,
                              color: _getFileColor(file.path),
                            ),
                            title: Text(p.basename(file.path)),
                            subtitle: Text(
                              file.path,
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _importFile(file),
                          );
                        }, childCount: _filteredFiles.length),
                      ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
