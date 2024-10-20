import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:cloud_storage_client/models/my_file.dart';

abstract class StorageService {
  // Common properties
  late String label;
  late String prefix;
  late Widget icon;

  // Common methods
  Future<List<MyFile>> getFolder({String? folderId});
  Future<io.File> downloadFile(String fileId);
  Future<bool> uploadFile({required String filePath, String? folderId});
  Future<bool> renameFile(String fileId, String newName);
  Future<bool> deleteFile(String fileId);
  Future<bool> createFolder({required String folderName, String? parentFolderId});
  Future<bool> deleteFolder(String folderId);
}

abstract class CloudStorageService extends StorageService {

  // Common methods
  static Future<CloudStorageService> addAccount() {
    // TODO: implement addAccount
    throw UnimplementedError();
  }

  static Future<CloudStorageService> removeAccount() {
    // TODO: implement removeAccount
    throw UnimplementedError();
  }

}