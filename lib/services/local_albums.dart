import 'dart:io';

import 'package:cloud_storage_client/services/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';


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
  static Future<bool> _verifyPermission() async {

    if (Platform.isLinux) {
      return true;
    }

    else if (Platform.isIOS || Platform.isAndroid || Platform.isWindows) {

      var status = await Permission.storage.status;

      if (!status.isGranted) {
        await Permission.storage.request();

        status = await Permission.storage.status;
        
        return status.isGranted;
      }

      return true;
    }

    else {
      throw Exception('Unsupported platform');
    }


  }

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
    var accessDirectories = await Storage.getAccessDirectories();
    var ignoreDirectories = await Storage.getIgnoreDirectories();

    var localAlbums = <LocalAlbum>[];

    if (kDebugMode) {
      print(accessDirectories);
      print(ignoreDirectories);
    }

    var status = await _verifyPermission();

    if (!status) {
      return localAlbums;
    }

    for (var directory in accessDirectories) {
      _recursiveDirectorySearch(directory, ignoreDirectories, localAlbums);
    }

    return localAlbums;
  }

  static Future<File> getCompressedImage(String imagePath) async {
    try {
      var status = await _verifyPermission();

      if (!status || Platform.isLinux) {
        return File(imagePath);
      }

      Directory tempDir = await Storage.getTemporaryFolder();
      String imageId = "local_$imagePath"; 

      if (File("${tempDir.path}/$imageId").existsSync()) {
        return File("${tempDir.path}/$imageId");
      }

      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        "${tempDir.path}/$imageId",
        quality: 50,
      );

      return File(compressedImage!.path);
      
    } catch (e) {
      
      if (kDebugMode) {
        print(e);
      }

      return File(imagePath);

    }

    
  }
}