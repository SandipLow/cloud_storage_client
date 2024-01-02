import 'dart:io';

import 'package:cloud_storage_client/services/storage.dart';
import 'package:flutter/foundation.dart';

class LocalAlbum {
  final String name;
  final String path;
  final String thumbnail;
  final List<String> files;
  

  LocalAlbum({
    required this.name,
    required this.path,
    required this.thumbnail,
    required this.files,
  });
}

class LocalAlbumService {
  static final _storage = Storage();

  static void _recursiveDirectorySearch( Directory current, List<Directory> ignoreDirectories, List<LocalAlbum> localAlbums ) {
    if (ignoreDirectories.map((e) => e.path).contains(current.path)) {
      return;
    }

    var images = <String>[];

    var files = current.listSync(followLinks: false);

    for (var file in files) {
      // ignore dot files
      if (file.path.split('/').last.startsWith('.')) {
        continue;
      }

      else if (file is Directory) {
        _recursiveDirectorySearch(file, ignoreDirectories, localAlbums);
      } 
      
      else if (file is File) {
        if (file.path.endsWith('.jpg') || file.path.endsWith('.png') || file.path.endsWith('.jpeg')) {
          images.add(file.path);
        }
      }
    } 

    if (images.isNotEmpty) {
      localAlbums.add(LocalAlbum(
        name: current.path.split('/').last,
        path: current.path,
        thumbnail: images.first,
        files: images,
      ));
    }
  }

  static Future getLocalAlbums() async {
    var accessDirectories = await _storage.getAccessDirectories();
    var ignoreDirectories = await _storage.getIgnoreDirectories();

    var localAlbums = <LocalAlbum>[];

    if (kDebugMode) {
      print(accessDirectories);
      print(ignoreDirectories);
    }

    for (var directory in accessDirectories) {
      _recursiveDirectorySearch(directory, ignoreDirectories, localAlbums);
    }

    return localAlbums;
  }
}