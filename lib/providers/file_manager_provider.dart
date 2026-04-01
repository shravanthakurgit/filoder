import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:external_path/external_path.dart';

enum SortOption { name, date, size }

class FileManagerProvider with ChangeNotifier {
  Directory? _currentDir;
  List<FileSystemEntity> _entities = [];
  List<FileSystemEntity> _filteredEntities = [];
  String _searchQuery = '';
  SortOption _sortOption = SortOption.name;
  bool _isAscending = true;

  Directory? get currentDir => _currentDir;
  List<FileSystemEntity> get entities => _filteredEntities;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  bool get isAscending => _isAscending;

  Future<void> init() async {
    String rootPath;
    if (Platform.isAndroid) {
      final list = await ExternalPath.getExternalStorageDirectories();
      rootPath = (list != null && list.isNotEmpty) ? list.first : '/storage/emulated/0';
    } else {
      final dir = await getApplicationDocumentsDirectory();
      rootPath = dir.path;
    }
    await setDirectory(Directory(rootPath));
  }

  Future<void> setDirectory(Directory dir) async {
    _currentDir = dir;
    _searchQuery = '';
    await loadEntities();
  }

  bool isRoot() {
    if (_currentDir == null) return true;
    final path = _currentDir!.path;
    if (Platform.isAndroid) {
      return path == '/storage/emulated/0' || path == '/storage/emulated/0/';
    }
    return false; // Standard app docs dir is usually the limit
  }

  Future<void> loadEntities() async {
    if (_currentDir == null) return;
    try {
      final list = _currentDir!.listSync();
      _entities = list;
      _applyFilterAndSort();
    } catch (e) {
      debugPrint('Error loading entities: $e');
      _entities = [];
      _filteredEntities = [];
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilterAndSort();
  }

  void setSortOption(SortOption option) {
    if (_sortOption == option) {
      _isAscending = !_isAscending;
    } else {
      _sortOption = option;
      _isAscending = true;
    }
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    _filteredEntities = _entities.where((entity) {
      final name = p.basename(entity.path).toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    _filteredEntities.sort((a, b) {
      // Prioritize Directory over File
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;

      int comparison = 0;
      switch (_sortOption) {
        case SortOption.name:
          comparison = p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase());
          break;
        case SortOption.date:
          comparison = a.statSync().modified.compareTo(b.statSync().modified);
          break;
        case SortOption.size:
          final aSize = a is File ? a.lengthSync() : 0;
          final bSize = b is File ? b.lengthSync() : 0;
          comparison = aSize.compareTo(bSize);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    notifyListeners();
  }

  Future<void> rename(FileSystemEntity entity, String newName) async {
    final parent = entity.parent.path;
    final extension = entity is File ? p.extension(entity.path) : '';
    final newPath = p.join(parent, '$newName$extension');
    await entity.rename(newPath);
    await loadEntities();
  }

  Future<void> delete(FileSystemEntity entity) async {
    await entity.delete(recursive: true);
    await loadEntities();
  }

  Future<void> createFolder(String name) async {
    if (_currentDir == null) return;
    final newPath = p.join(_currentDir!.path, name);
    await Directory(newPath).create();
    await loadEntities();
  }

  Future<void> copy(FileSystemEntity entity, String targetPath) async {
    if (entity is File) {
      await entity.copy(p.join(targetPath, p.basename(entity.path)));
    } else if (entity is Directory) {
      final newDir = await Directory(p.join(targetPath, p.basename(entity.path))).create();
      await for (final child in entity.list(recursive: false)) {
        await copy(child, newDir.path);
      }
    }
    await loadEntities();
  }

  Future<void> move(FileSystemEntity entity, String targetPath) async {
    await copy(entity, targetPath);
    await delete(entity);
  }

  bool goBack() {
    if (_currentDir == null) return false;
    final parent = _currentDir!.parent;
    if (parent.path == _currentDir!.path) return false;
    setDirectory(parent);
    return true;
  }
}
