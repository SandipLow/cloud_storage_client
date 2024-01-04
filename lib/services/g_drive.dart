import 'dart:io' as io;
import 'package:cloud_storage_client/models/my_file.dart';
import 'package:cloud_storage_client/res/assets.dart';
import 'package:cloud_storage_client/res/strings.dart';
import 'package:cloud_storage_client/services/storage.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/people/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';


List<String> _scopes = [
  DriveApi.driveScope,
  PeopleServiceApi.userinfoEmailScope,
  PeopleServiceApi.userinfoProfileScope
];


Map<String, Map<String, Icon>> _mimeTypes = {
  "application/vnd.google-apps.folder": { Strings.FILE_TYPES_FOLDER: const Icon(Icons.folder)}, 

  "application/vnd.google-apps.document": { "Document": const Icon(Icons.article) },
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document": { "Document": const Icon(Icons.article) },
  "application/msword": { "Document": const Icon(Icons.article) },
  "text/plain": { "Document": const Icon(Icons.article) },
  "application/rtf": { "Document": const Icon(Icons.article) },

  "application/vnd.google-apps.spreadsheet": { "Spreadsheet": const Icon(Icons.table_chart) },
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": { "Spreadsheet": const Icon(Icons.table_chart) },
  "text/csv": { "Spreadsheet": const Icon(Icons.table_chart) },
  
  "application/vnd.google-apps.presentation": { "Presentation": const Icon(Icons.slideshow) },
  "application/vnd.ms-powerpoint": { "Presentation": const Icon(Icons.slideshow) },
  "application/vnd.openxmlformats-officedocument.presentationml.presentation": { "Presentation": const Icon(Icons.slideshow) },

  "image/jpeg": { "Image": const Icon(Icons.image) },
  "image/png": { "Image": const Icon(Icons.image) },
  "image/gif": { "Image": const Icon(Icons.image) },
  "image/bmp": { "Image": const Icon(Icons.image) },
  "image/svg+xml": { "Image": const Icon(Icons.image) },
  
  "audio/mpeg": { "Audio": const Icon(Icons.audiotrack) },
  "audio/wav": { "Audio": const Icon(Icons.audiotrack) },
  
  "video/mp4": { "Video": const Icon(Icons.video_library) },
  "video/x-msvideo": { "Video": const Icon(Icons.video_library) },
  "video/x-matroska": { "Video": const Icon(Icons.video_library) },
  
  "application/zip": { "Archive": const Icon(Icons.archive) },
  "application/vnd.rar": { "Archive": const Icon(Icons.archive) },
  
  "application/vnd.google-apps.sites": { "Web": const Icon(Icons.web) },
  "application/vnd.google-apps.script": { "Code": const Icon(Icons.code) },
  "text/html": { "Code": const Icon(Icons.code) },
  "application/xml": { "Code": const Icon(Icons.code) },
  "application/json": { "Code": const Icon(Icons.code) },
  "application/javascript": { "Code": const Icon(Icons.code) },
  "text/css": { "Code": const Icon(Icons.code) },
};



class GoogleDrive {
  // storage instance to manage data in flutter storage
  static final _storage = Storage();
  
  // email / username in the provider
  late String label;
  
  // reference in storage
  String prefix = Strings.GOOGLE_DRIVE_PREFIX;
  
  // Icon of the service
  Widget icon = const Image(image: Images.googleDrive);

  
  // Constructor
  GoogleDrive({required this.label});


  // Create drive account
  static Future<GoogleDrive> addAccount() async {
    //Needs user authentication
    var authClient = await clientViaUserConsent(
        ClientId(
            Strings.GOOGLE_DRIVE_CLIENTID,
            Strings.GOOGLE_DRIVE_CLIENTSECRET
        ),
        _scopes,
            (url) {
          //Open Url in Browser
          launchUrl(Uri.parse(url));
        });

    // Get user email
    var people = PeopleServiceApi(authClient);
    var profile = await people.people.get("people/me", personFields: "emailAddresses");
    var email = profile.emailAddresses!.first.value;

    if (email == null) throw Exception("Email not found");

    // save drive
    await _storage.addDrive(Strings.GOOGLE_DRIVE_PREFIX, email);

    //Save Credentials
    await _storage.saveGDriveCredentials(email, authClient.credentials.accessToken, authClient.credentials.refreshToken);
    return GoogleDrive(label: authClient.credentials.accessToken.data);
  }

  // http client
  Future<http.Client> _getClient() async {
    //Get Credentials from storage
    var credentials = await _storage.getGDriveCredentials(label);

    if (credentials == null) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
        ClientId(
          Strings.GOOGLE_DRIVE_CLIENTID,
          Strings.GOOGLE_DRIVE_CLIENTSECRET
        ),
        _scopes,
        (url) {
            //Open Url in Browser
            launchUrl(Uri.parse(url));
        });
      //Save Credentials
      await _storage.saveGDriveCredentials(label, authClient.credentials.accessToken, authClient.credentials.refreshToken);
      return authClient;
    } 
  
    // handle expired credentials
    if (DateTime.parse(credentials["expiry"]).isBefore(DateTime.now())) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
        ClientId(
          Strings.GOOGLE_DRIVE_CLIENTID,
          Strings.GOOGLE_DRIVE_CLIENTSECRET
        ),
        _scopes,
        (url) {
            //Open Url in Browser
            launchUrl(Uri.parse(url));
        });
      //Save Credentials
      await _storage.saveGDriveCredentials(label, authClient.credentials.accessToken, authClient.credentials.refreshToken);
      return authClient;
    }

    //Already authenticated
    return authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
          credentials["tokenType"], 
          credentials["tokenData"],
          DateTime.tryParse(credentials["expiry"]) ?? DateTime.now().add(const Duration(hours: 1))
        ),
        credentials["refreshToken"],
        _scopes
      )
    );
  }
  
  // Get folder contents
  Future<List<MyFile>> getFolder({String? folderId}) async {
    var client = await _getClient();
    var drive = DriveApi(client);
    var files = await drive.files.list(
      q: "trashed = false and '${folderId ?? "root"}' in parents",
      $fields: "files(id, name, mimeType, thumbnailLink)"
    );

    return files.files!.map((e) => MyFile(
      id: e.id!,
      name: e.name!,

      type: _mimeTypes[e.mimeType]!=null ? _mimeTypes[e.mimeType]!.keys.first
             : Strings.FILE_TYPES_UNKNOWN,

      icon: _mimeTypes[e.mimeType]!=null ? _mimeTypes[e.mimeType]!.values.first
            : const ImageIcon(Images.unknownFile),

    )).toList();

  }
  
  // Download File
  Future<io.File> downloadFile(String fileId) async {
    io.Directory tempDir = await _storage.getTemporaryFolder();

    final fileName = '${Strings.TEMPORARY_FILE_PREFIX}_${Strings.GOOGLE_DRIVE_PREFIX}_${label}_$fileId';
    final file = io.File('${tempDir.path}/$fileName');

    if (await file.exists()) {
      return file;
    }

    var client = await _getClient();
    var driveApi = DriveApi(client);
    var response = await driveApi.files.get(fileId, downloadOptions: DownloadOptions.fullMedia) as Media;
    var bytes = await http.ByteStream(response.stream).toBytes();

    await file.writeAsBytes(bytes);
    return file;
  }

  // upload file
  Future uploadFile(String filePath, String? folderId, String? fileName) async {
    var client = await _getClient();
    var drive = DriveApi(client);
    var file = File();

    file.name = fileName ?? filePath.split("/").last;
    file.parents = [folderId ?? "root"];

    var response = await drive.files.create(
      file, 
      uploadMedia: Media(
        Stream.fromIterable([await io.File(filePath).readAsBytes()]), 
        io.File(filePath).lengthSync()
      )
    );
    return response;
  }

}