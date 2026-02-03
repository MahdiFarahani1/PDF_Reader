import 'package:flutter/material.dart';
import 'package:flutter_application_1/logic/cubits/settings/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../data/models/document_model.dart';
import '../../../logic/cubits/library/library_cubit.dart';
import '../../../logic/cubits/library/library_state.dart';
import '../reader/reader_screen.dart';
import '../settings/settings_screen.dart';
import 'scanner_screen.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/snackbar_common.dart';
import '../../../core/widgets/dialog_common.dart';
import '../../../data/models/category_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.myLibrary,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Image.asset(
              AppIcons.addDocument,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _showAddCategoryDialog(context),
          ),
          IconButton(
            icon: Image.asset(
              AppIcons.nightDay,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              final settingsCubit = context.read<SettingsCubit>();
              final currentMode = settingsCubit.state.themeMode;
              final newMode = currentMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              settingsCubit.toggleTheme(newMode);
            },
          ),
          IconButton(
            icon: Image.asset(
              AppIcons.settings,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: loc.settings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          if (state.status == LibraryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppIcons.bookAlt,
                    width: 120,
                    height: 120,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.noDocuments,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.tapToImport,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Filter documents if a category is selected
          final filteredDocs = state.selectedCategoryId == null
              ? state.documents
              : state.documents
                    .where((doc) => doc.categoryId == state.selectedCategoryId)
                    .toList();

          // Group documents by FileType
          final Map<FileType, List<DocumentModel>> groupedDocs = {};
          for (var doc in filteredDocs) {
            if (!groupedDocs.containsKey(doc.fileType)) {
              groupedDocs[doc.fileType] = [];
            }
            groupedDocs[doc.fileType]!.add(doc);
          }

          final sortedKeys = groupedDocs.keys.toList()
            ..sort((a, b) => a.index.compareTo(b.index));

          return Column(
            children: [
              if (state.categories.isNotEmpty)
                _CategoryList(
                  categories: state.categories,
                  selectedId: state.selectedCategoryId,
                ),
              if (filteredDocs.isEmpty && state.selectedCategoryId != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(loc.noDocsInCategory),
                        TextButton(
                          onPressed: () => context
                              .read<LibraryCubit>()
                              .setCategoryFilter(null),
                          child: Text(loc.clearFilter),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, sectionIndex) {
                      final type = sortedKeys[sectionIndex];
                      final docs = groupedDocs[type]!;

                      String sectionTitle;
                      switch (type) {
                        case FileType.pdf:
                          sectionTitle = loc.pdfDocument;
                          break;
                        case FileType.epub:
                          sectionTitle = loc.epubDocument;
                          break;
                        case FileType.txt:
                          sectionTitle = loc.txtDocument;
                          break;
                        case FileType.word:
                          sectionTitle = loc.wordDocument;
                          break;
                        case FileType.sheet:
                          sectionTitle = loc.sheetDocument;
                          break;
                        default:
                          sectionTitle = loc.others;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                            child: Row(
                              children: [
                                Image.asset(
                                  _getSectionIcon(type),
                                  color: Theme.of(context).primaryColor,
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    sectionTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  maxRadius: 14,
                                  child: Text(
                                    '${docs.length}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              return _DocumentCard(document: docs[index]);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
        },
        label: Text(loc.import),
        icon: Image.asset(
          AppIcons.squareDashedCirclePlus,
          width: 24,
          height: 24,
          color: Colors.white,
        ),
        elevation: 4,
      ),
    );
  }

  String _getSectionIcon(FileType type) {
    switch (type) {
      case FileType.pdf:
        return AppIcons.filePdf;
      case FileType.epub:
        return AppIcons.bookAlt;
      case FileType.txt:
        return AppIcons.file;
      case FileType.word:
        return AppIcons.fileWord;
      case FileType.sheet:
        return AppIcons.addDocument;
      default:
        return AppIcons.document;
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);

    AppDialog.showFieldDialog(
      context,
      title: loc.newCategory,
      content: loc.enterCategoryName,
      onPress: (value) async {
        if (value.trim().isNotEmpty) {
          context.read<LibraryCubit>().createCategory(value.trim());
          AppSnackBar.showSuccess(context, loc.categoryCreated);
        }
      },
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;

  const _CategoryList({required this.categories, this.selectedId});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(loc.all),
              selected: selectedId == null,
              onSelected: (selected) {
                if (selected) {
                  context.read<LibraryCubit>().setCategoryFilter(null);
                }
              },
            ),
          ),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InputChip(
                label: Text(category.name),
                selected: selectedId == category.id,
                onSelected: (selected) {
                  context.read<LibraryCubit>().setCategoryFilter(
                    selected ? category.id : null,
                  );
                },
                onDeleted: () {
                  AppDialog.showConfirmDialog(
                    context,
                    title: loc.deleteCategory,
                    content: loc.deleteCategoryDesc,
                    onPress: () async {
                      context.read<LibraryCubit>().deleteCategory(category.id);
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentModel document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReaderScreen(document: document),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getColorForFileType(document.fileType).withOpacity(0.1),
                _getColorForFileType(document.fileType).withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, top: 8, right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorForFileType(document.fileType),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        document.fileType.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) {
                        switch (value) {
                          case 'rename':
                            _showRenameDialog(context, document);
                            break;
                          case 'category':
                            _showMoveToCategoryDialog(context, document);
                            break;
                          case 'info':
                            _showInfoDialog(context, document);
                            break;
                          case 'share':
                            Share.shareXFiles(
                              [XFile(document.path)],
                              text:
                                  'Check out this document: ${document.title}',
                            );
                            break;
                          case 'open_external':
                            OpenFilex.open(document.path);
                            break;
                          case 'delete':
                            _showDeleteDialog(context, document);
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        final loc = AppLocalizations.of(context);
                        return [
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Image.asset(
                                  AppIcons.pencil,
                                  width: 18,
                                  height: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                const SizedBox(width: 12),
                                Text(loc.rename),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'category',
                            child: Row(
                              children: [
                                Image.asset(
                                  AppIcons.folder,
                                  width: 18,
                                  height: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                const SizedBox(width: 12),
                                Text(loc.moveToCategory),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'info',
                            child: Row(
                              children: [
                                Image.asset(
                                  AppIcons.fileCircleInfo,
                                  width: 18,
                                  height: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                const SizedBox(width: 12),
                                Text(loc.details),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.share,
                                  size: 18,
                                  color: Color.fromARGB(255, 0, 184, 141),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  loc.share,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 184, 141),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'open_external',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.open_in_new,
                                  size: 18,
                                  color: Color.fromARGB(255, 0, 184, 141),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  loc.openWithExternal,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 184, 141),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Image.asset(
                                  AppIcons.trash,
                                  width: 18,
                                  height: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  loc.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ),

              // Icon
              Expanded(
                child: Center(
                  child: Image.asset(
                    _getIconForFileType(document.fileType),
                    width: 64,
                    height: 64,
                    color: _getColorForFileType(document.fileType),
                  ),
                ),
              ),

              // Document Info
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset(
                          AppIcons.clockThree,
                          width: 14,
                          height: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(document.dateAdded, context),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Image.asset(
                          AppIcons.folder,
                          width: 14,
                          height: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${document.size.toStringAsFixed(2)} MB',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    if (document.categoryId != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.label_outline,
                            size: 14,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: BlocBuilder<LibraryCubit, LibraryState>(
                              builder: (context, state) {
                                final loc = AppLocalizations.of(context);
                                final category = state.categories.firstWhere(
                                  (cat) => cat.id == document.categoryId,
                                  orElse: () => CategoryModel(
                                    id: '',
                                    name: loc.unknown,
                                    dateCreated: DateTime.now(),
                                  ),
                                );
                                return Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForFileType(FileType type) {
    switch (type) {
      case FileType.pdf:
        return Colors.red;
      case FileType.epub:
        return Colors.orange;
      case FileType.txt:
        return Colors.blueGrey;
      case FileType.word:
        return Colors.blue;
      case FileType.sheet:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getIconForFileType(FileType type) {
    switch (type) {
      case FileType.pdf:
        return AppIcons.filePdf;
      case FileType.epub:
        return AppIcons.bookAlt;
      case FileType.txt:
        return AppIcons.file;
      case FileType.word:
        return AppIcons.fileWord;
      case FileType.sheet:
        return AppIcons.addDocument;
      default:
        return AppIcons.document;
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
    final loc = AppLocalizations.of(context);

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return loc.today;
    } else if (difference.inDays == 1) {
      return loc.yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${loc.daysAgo}';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _showRenameDialog(BuildContext context, DocumentModel document) {
    final loc = AppLocalizations.of(context);
    AppDialog.showFieldDialog(
      context,
      title: loc.renameFile,
      content: '${loc.enterNewName} "${document.title}":',
      initialValue: document.title,
      onPress: (value) async {
        final newName = value.trim();
        if (newName.isNotEmpty) {
          final updatedDoc = document.copyWith(title: newName);
          context.read<LibraryCubit>().updateDocument(updatedDoc);
          AppSnackBar.showSuccess(context, loc.fileRenamed);
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentModel document) {
    final loc = AppLocalizations.of(context);
    AppDialog.showConfirmDialog(
      context,
      title: loc.deleteFile,
      content: '${loc.deleteFileDesc} "${document.title}"?',
      onPress: () async {
        context.read<LibraryCubit>().removeDocument(document.id);
        AppSnackBar.showSuccess(context, loc.fileDeleted);
      },
    );
  }

  void _showInfoDialog(BuildContext context, DocumentModel document) {
    final loc = AppLocalizations.of(context);
    final infoMessage =
        '${loc.name}: ${document.title}\n'
        '${loc.path}: ${document.path}\n'
        '${loc.size}: ${document.size.toStringAsFixed(2)} MB\n'
        '${loc.type}: ${document.fileType.name.toUpperCase()}\n'
        '${loc.added}: ${DateFormat('MMM d, yyyy HH:mm').format(document.dateAdded)}';

    AppDialog.showInfoDialog(context, loc.fileDetails, infoMessage);
  }

  void _showMoveToCategoryDialog(BuildContext context, DocumentModel document) {
    final loc = AppLocalizations.of(context);

    final categories = context.read<LibraryCubit>().state.categories;

    if (categories.isEmpty) {
      AppSnackBar.showWarning(context, loc.noCategories);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.moveToCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(loc.uncategorized),
              leading: const Icon(Icons.clear),
              selected: document.categoryId == null,
              onTap: () {
                context.read<LibraryCubit>().assignDocumentToCategory(
                  document.id,
                  null,
                );
                Navigator.pop(context);
                AppSnackBar.showSuccess(context, loc.movedToUncategorized);
              },
            ),
            const Divider(),
            ...categories.map(
              (cat) => ListTile(
                title: Text(cat.name),
                leading: Image.asset(AppIcons.folder, width: 20, height: 20),
                selected: document.categoryId == cat.id,
                onTap: () {
                  context.read<LibraryCubit>().assignDocumentToCategory(
                    document.id,
                    cat.id,
                  );
                  Navigator.pop(context);
                  AppSnackBar.showSuccess(
                    context,
                    '${loc.movedTo} ${cat.name}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
