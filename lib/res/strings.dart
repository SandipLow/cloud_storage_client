// ignore_for_file: constant_identifier_names

import 'package:cloud_storage_client/res/secrets.dart';

class Strings {
  static const String GOOGLE_DRIVE_PREFIX = "g_drive";
  static const String GOOGLE_DRIVE_CLIENTID = Secrets.GOOGLE_DRIVE_CLIENTID;
  static const String GOOGLE_DRIVE_CLIENTSECRET = Secrets.GOOGLE_DRIVE_CLIENTSECRET;

  static const String YANDEX_DISK_PREFIX = "yandex";
  static const String YANDEX_CLIENTID = Secrets.YANDEX_CLIENTID;
  static const String YANDEX_CLIENTSECRET = Secrets.YANDEX_CLIENTSECRET;
  static const String YANDEX_REDIRECTURI = Secrets.YANDEX_REDIRECTURI;

  static const String FILE_TYPES_FOLDER = "Folder";
  static const String FILE_TYPES_IMAGE = "Image";
  static const String FILE_TYPES_VIDEO = "Video";
  static const String FILE_TYPES_AUDIO = "Audio";
  static const String FILE_TYPES_DOCUMENT = "Document";
  static const String FILE_TYPES_SPREADSHEET = "Spreadsheet";
  static const String FILE_TYPES_PRESENTATION = "Presentation";
  static const String FILE_TYPES_ARCHIVE = "Archive";
  static const String FILE_TYPES_WEB = "Web";
  static const String FILE_TYPES_CODE = "Code";
  static const String FILE_TYPES_UNKNOWN = "Unknown";
  
  static const String TEMPORARY_FILE_PREFIX = "temporary_file";
}