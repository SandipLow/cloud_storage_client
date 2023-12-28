// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:cloud_storage_client/models/my_drive.dart';
import 'package:cloud_storage_client/res/assets.dart';
import 'package:cloud_storage_client/res/strings.dart';
import 'package:cloud_storage_client/services/g_drive.dart';
import 'package:cloud_storage_client/services/yandex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis_auth/googleapis_auth.dart';


class Storage {
  static const _storage = FlutterSecureStorage();
  static const String _seperator = "[@#%#@]";


  // Authenticated Cloud Drives' info Storage
  Future<List<MyDrive>> getDrives() async {
    List<MyDrive> drives = [];

    // Google Drive
    String? googleDrives = await _storage.read(key: Strings.GOOGLE_DRIVE_PREFIX);

    if (googleDrives != null) {
      List<String> emails = googleDrives.split(_seperator);
      for (var email in emails) {
        drives.add(
            MyDrive(
                label: email,
                prefix: Strings.GOOGLE_DRIVE_PREFIX,
                icon: const Image(image: Images.googleDrive, width: 24, height: 24),
                providerService: GoogleDrive(label: email)
            )
        );
      }
    }


    // Yandex
    String? yandexes = await _storage.read(key: Strings.YANDEX_DISK_PREFIX);

    if (yandexes != null) {
      List<String> emails = yandexes.split(_seperator);
      for (var email in emails) {
        drives.add(
            MyDrive(
                label: email,
                prefix: Strings.YANDEX_DISK_PREFIX,
                icon: const Image(image: Images.yandex, width: 24, height: 24),
                providerService: YandexDisk(label: email)
            )
        );
      }
    }

    return drives;
  }

  Future removeDrive(String prefix, String label) async {
    String? labels = await _storage.read(key: prefix);
    if (labels == null) return;

    List<String> drives = labels.split(_seperator);
    drives.remove(label);

    labels = drives.join(_seperator);

    await _storage.write(key: prefix, value: labels);
  }

  Future addDrive(String prefix, String label) async {
    String? labels = await _storage.read(key: prefix);

    if (labels == null) {
      // If no labels exist for this prefix, create a new list with the provided label
      labels = label;
    } else {
      // If labels exist, append the new label
      List<String> drives = labels.split(_seperator);
      if (!drives.contains(label)) {
        drives.add(label);
        labels = drives.join(_seperator);
      } else {
        // Label already exists, handle as needed (throw an error, return, etc.)
        // For example, you might throw an error indicating the label already exists
        throw Exception("Label already exists for $prefix");
      }
    }

    // Update the storage with the modified labels
    await _storage.write(key: prefix, value: labels);
  }


  // Google Drives' info Storage
  Future saveGDriveCredentials(String email, AccessToken accessToken, String? refreshToken) async {
    // Serialize the access token to store it in secure storage
    Map<String, dynamic> tokenMap = {
      'tokenType': accessToken.type,
      'tokenData': accessToken.data,
      'expiry': accessToken.expiry.toString(),
      'refreshToken': refreshToken,
    };

    // Convert the tokenMap to a string (you might want to use JSON encoding)
    String tokenString = jsonEncode(tokenMap);

    // Store the tokenString securely, for example, using FlutterSecureStorage
    await _storage.write(
        key: '${Strings.GOOGLE_DRIVE_PREFIX}_$email',
        value: tokenString
    );
  }

  Future<Map?> getGDriveCredentials(String email) async {
    String? tokenString = await _storage.read(key: '${Strings.GOOGLE_DRIVE_PREFIX}_$email');
    if (tokenString==null) return null;

    return jsonDecode(tokenString) as Map;
  }

  Future removeGDriveCredentials(String email) async {
    await _storage.delete(key: '${Strings.GOOGLE_DRIVE_PREFIX}_$email');
  }


  // Yandex Disks' info storage
  Future saveYandexCredentials(String accessToken, String email) async {
    // Store the Yandex credentials securely
    await _storage.write(key: '${Strings.YANDEX_DISK_PREFIX}_$email', value: accessToken);
  }

  Future<Map?> getYandexCredentials(String email) async {
    // Retrieve Yandex credentials from secure storage
    String? accessToken = await _storage.read(key: '${Strings.YANDEX_DISK_PREFIX}_$email');

    if (accessToken==null) return null;

    return {
      "accessToken": accessToken,
    };
    
  }

  Future removeYandexCredentials(String email) async {
    await _storage.delete(key: '${Strings.YANDEX_DISK_PREFIX}_$email');
  }


  // Folder settings
  static const String _TEMPORARY_FOLDER_KEY = "temporaryFolder";
  static const String _ACCESS_DIRECTORIES_KEY = "accessDirectories";
  static const String _IGNORE_DIRECTORIES_KEY = "ignoreDirectories";

  Future<Map<String, dynamic>> defaultFolderSetting() async {
    if (Platform.isAndroid) {
      var tempDir = "/storage/emulated/0/Android/data/com.sdek.cloud_storage_client/files";
      var accessDirs = ["/storage/emulated/0"];
      var ignoreDirs = ["/storage/emulated/0/Android"];

      await _storage.write(key: _TEMPORARY_FOLDER_KEY, value: tempDir);
      await _storage.write(key: _ACCESS_DIRECTORIES_KEY, value: accessDirs.join(_seperator));
      await _storage.write(key: _IGNORE_DIRECTORIES_KEY, value: ignoreDirs.join(_seperator));

      return {
        _TEMPORARY_FOLDER_KEY: tempDir,
        _ACCESS_DIRECTORIES_KEY: accessDirs,
        _IGNORE_DIRECTORIES_KEY: ignoreDirs,
      };
    }

    else if (Platform.isLinux) {
      ProcessResult result = await Process.run('whoami', []);
      String username = result.stdout.toString().trim();

      var tempDir = "/home/$username/.cloud_storage_client";
      var accessDirs = ["/home/$username"];
      var ignoreDirs = ["/home/$username/snap"];

      await _storage.write(key: _TEMPORARY_FOLDER_KEY, value: tempDir);
      await _storage.write(key: _ACCESS_DIRECTORIES_KEY, value: accessDirs.join(_seperator));
      await _storage.write(key: _IGNORE_DIRECTORIES_KEY, value: ignoreDirs.join(_seperator));

      return {
        _TEMPORARY_FOLDER_KEY: tempDir,
        _ACCESS_DIRECTORIES_KEY: accessDirs,
        _IGNORE_DIRECTORIES_KEY: ignoreDirs,
      };
    }

    else {
      throw Exception("Unsupported platform");
    }
  }

  Future<Directory> getTemporaryFolder() async {
    var path = await _storage.read(key: "temporaryFolder");

    if (path == null) {
      var settings = await defaultFolderSetting();
      return Directory(settings["temporaryFolder"]);
    }

    return Directory(path);
  }

  Future setTemporaryFolder(String folder) async {
    await _storage.write(key: "temporaryFolder", value: folder);
  }

  Future<List<Directory>> getAccessDirectories() async {
    var paths = await _storage.read(key: _ACCESS_DIRECTORIES_KEY);

    if (paths == null) {
      var settings = await defaultFolderSetting();
      return [Directory(settings[_ACCESS_DIRECTORIES_KEY])];
    }

    List<String> directories = paths.split(_seperator);
    List<Directory> dirs = [];
    for (var path in directories) {
      dirs.add(Directory(path));
    }

    return dirs;
  }

  Future addAccessDirectory(String path) async {
    var paths = await _storage.read(key: _ACCESS_DIRECTORIES_KEY);

    if (paths == null) {
      await _storage.write(key: _ACCESS_DIRECTORIES_KEY, value: path);
    } else {
      List<String> directories = paths.split(_seperator);
      if (!directories.contains(path)) {
        directories.add(path);
        paths = directories.join(_seperator);
        await _storage.write(key: _ACCESS_DIRECTORIES_KEY, value: paths);
      }
    }
  }

  Future removeAccessDirectory(String path) async {
    var paths = await _storage.read(key: _ACCESS_DIRECTORIES_KEY);

    if (paths == null) {
      return;
    } else {
      List<String> directories = paths.split(_seperator);
      if (directories.contains(path)) {
        directories.remove(path);
        paths = directories.join(_seperator);
        await _storage.write(key: _ACCESS_DIRECTORIES_KEY, value: paths);
      }
    }
  }

  Future<List<Directory>> getIgnoreDirectories() async {
    var paths = await _storage.read(key: _IGNORE_DIRECTORIES_KEY);

    if (paths == null) {
      var settings = await defaultFolderSetting();
      return [Directory(settings[_IGNORE_DIRECTORIES_KEY])];
    }

    List<String> directories = paths.split(_seperator);
    List<Directory> dirs = [];
    for (var path in directories) {
      dirs.add(Directory(path));
    }

    return dirs;
  }

  Future addIgnoreDirectory(String path) async {
    var paths = await _storage.read(key: _IGNORE_DIRECTORIES_KEY);

    if (paths == null) {
      await _storage.write(key: _IGNORE_DIRECTORIES_KEY, value: path);
    } else {
      List<String> directories = paths.split(_seperator);
      if (!directories.contains(path)) {
        directories.add(path);
        paths = directories.join(_seperator);
        await _storage.write(key: _IGNORE_DIRECTORIES_KEY, value: paths);
      }
    }
  }

  Future removeIgnoreDirectory(String path) async {
    var paths = await _storage.read(key: _IGNORE_DIRECTORIES_KEY);

    if (paths == null) {
      return;
    } else {
      List<String> directories = paths.split(_seperator);
      if (directories.contains(path)) {
        directories.remove(path);
        paths = directories.join(_seperator);
        await _storage.write(key: _IGNORE_DIRECTORIES_KEY, value: paths);
      }
    }
  }

}