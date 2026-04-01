import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../providers/file_manager_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/action_bottom_sheet.dart';
import '../widgets/file_card.dart';
import '../widgets/sort_menu.dart';
import 'package:open_filex/open_filex.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileManagerProvider>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FileManagerProvider>();
    final currentPath = provider.currentDir?.path ?? 'Loading...';
    final name = p.basename(currentPath);

    return PopScope(
      canPop: provider.isRoot(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!provider.isRoot()) {
          provider.goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: const InputDecoration(
                    hintText: 'Search files...',
                    border: InputBorder.none,
                  ),
                )
              : Row(
                  children: [
                    Image.asset('assets/logo.png', height: 28),
                    const SizedBox(width: 12),
                    Text(name.isEmpty || name == '/' ? 'Filoder' : name),
                  ],
                ),
          leading: !provider.isRoot() && !_isSearching
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => provider.goBack(),
                )
              : null,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  }
                });
              },
            ),
            const SortMenu(),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: provider.entities.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: provider.entities.length,
                      itemBuilder: (context, index) {
                        final entity = provider.entities[index];
                        return FileCard(
                          entity: entity,
                          onTap: () {
                            if (entity is Directory) {
                              provider.setDirectory(entity);
                            } else {
                              OpenFilex.open(entity.path).then((result) {
                                if (result.type != ResultType.done) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error opening file: ${result.message}')),
                                  );
                                }
                              });
                            }
                          },
                          onLongPress: () => _showActions(context, entity),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateFolderDialog(context),
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', width: 80, height: 80),
          const SizedBox(height: 16),
          Text(
            'No files found',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, FileSystemEntity entity) {
    final provider = context.read<FileManagerProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionBottomSheet(
        entity: entity,
        onRename: (newName) => provider.rename(entity, newName),
        onDelete: () => provider.delete(entity),
        onCopy: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copy feature simulated. Please select destination.')),
          );
        },
        onMove: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Move feature simulated.')),
          );
        },
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    final provider = context.read<FileManagerProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.createFolder(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
