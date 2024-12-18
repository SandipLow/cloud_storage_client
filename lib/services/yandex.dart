// ignore_for_file: overridden_fields

import 'dart:convert';
import 'dart:io';

import 'package:cloud_storage_client/models/my_file.dart';
import 'package:cloud_storage_client/res/assets.dart';
import 'package:cloud_storage_client/res/strings.dart';
import 'package:cloud_storage_client/services/storage_service.dart';
import 'package:cloud_storage_client/services/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


const List<String> _scopes = [
  "login:email",
  "cloud_api:disk.write",
  "cloud_api:disk.read",
  "cloud_api:disk.info",
  "cloud_api:disk.app_folder",
];


Map<String, Map<String, Icon>> _mimeTypes = {
  "application/msword": { "Document": const Icon(Icons.article) },
  "text/plain": { "Document": const Icon(Icons.article) },
  "application/rtf": { "Document": const Icon(Icons.article) },

  "text/csv": { "Spreadsheet": const Icon(Icons.table_chart) },

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

  "text/html": { "HTML": const Icon(Icons.language) },
  "application/xml": { "XML": const Icon(Icons.code) },
  "application/json": { "JSON": const Icon(Icons.code) },
  "application/javascript": { "JavaScript": const Icon(Icons.code) },
  "text/css": { "CSS": const Icon(Icons.style) },
};


class YandexClient {
  final client = http.Client();
  final String accessToken;

  static final Uri authUri = Uri(
    scheme: 'https',
    host: 'oauth.yandex.com',
    path: '/authorize',
    queryParameters: {
      'response_type': 'code',
      'client_id': Strings.YANDEX_CLIENTID,
      'redirect_uri': Strings.YANDEX_REDIRECTURI,
      'scope': _scopes.join(' '),
    },
  );

  static final Uri tokenUri = Uri(
    scheme: 'https',
    host: 'oauth.yandex.com',
    path: '/token',
  );

  static final Uri userEmailUri = Uri(
    scheme: 'https',
    host: 'login.yandex.ru',
    path: '/info',
  );


  YandexClient({required this.accessToken});

  static Future<YandexClient> clientViaUserConsent() async {
    //Open Url in Browser
    launchUrl(authUri);

    // making http server to listen for the redirect uri
    var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    String? code;

    // listening for the redirect uri
    await for (HttpRequest request in server) {
      if (request.method == "GET" && request.uri.path == "/redirect/yandex") {
        // getting the code from the uri
        code = request.uri.queryParameters["code"];

        // closing the server
        request.response.write("You can close this tab now");
        await request.response.close();
        await server.close(force: true);
      }

      else {
        request.response.write("Invalid Request");
        await request.response.close();
      }
    }

    if (code == null) {
      throw Exception("No code received");
    }

    // getting the access token
    var response = await http.post(
      tokenUri,
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'client_id': Strings.YANDEX_CLIENTID,
        'client_secret': Strings.YANDEX_CLIENTSECRET,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error getting access token");
    }

    var data = jsonDecode(response.body);

    // getting the access token from the response
    var accessToken = data["access_token"];

    // returning the client
    return YandexClient(accessToken: accessToken);
    
  }

  getEmail() async {
    var response = await get(userEmailUri);
    if (response.statusCode != 200) {
      throw Exception("Error getting email");
    }

    var data = jsonDecode(response.body);
    return data["default_email"];
    
  }

  get(Uri uri) {
    return client.get(
      uri,
      headers: {
        "Authorization": "OAuth $accessToken"
      },
    );
  }

  post(Uri uri, {dynamic body}) {
    return client.post(
      uri,
      headers: {
        "Authorization": "OAuth $accessToken"
      },
      body: body,
    );
  }

  put(Uri uri, {dynamic body}) {
    return client.put(
      uri,
      headers: {
        "Authorization": "OAuth $accessToken"
      },
      body: body,
    );
  }

  delete(Uri uri) {
    return client.delete(
      uri,
      headers: {
        "Authorization": "OAuth $accessToken"
      },
    );
  }

  close() {
    client.close();
  }
 }


class YandexDisk extends CloudStorageService {
  // email / username in the provider
  @override
  late String label;
  
  // reference in storage
  @override
  String prefix = Strings.GOOGLE_DRIVE_PREFIX;
  
  // Icon of the service
  @override
  Widget icon = const Image(image: Images.googleDrive);

  
  // Constructor
  YandexDisk({required this.label});


  // add new account
  static Future<YandexDisk> addAccount() async {
    //Needs user authentication
    var authClient = await YandexClient.clientViaUserConsent();
    
    //Get Email
    var email = await authClient.getEmail();

    // save drive
    await Storage.addDrive(Strings.YANDEX_DISK_PREFIX, email);

    //Save Credentials
    await Storage.saveYandexCredentials(email, authClient.accessToken);

    return YandexDisk(label: email);
  }

  // http client
  Future<YandexClient> _getClient() async {
    //Get Credentials
    var credentials = await Storage.getYandexCredentials(label);

    if (credentials==null) {
      //Needs user authentication
      var authClient = await YandexClient.clientViaUserConsent();
      
      //Save Credentials
      await Storage.saveYandexCredentials(label, authClient.accessToken);
      return authClient;
    }

    return YandexClient(accessToken: credentials["accessToken"]);
  }

  // get Folder contents
  @override
  Future<List<MyFile>> getFolder({ String? folderId}) async {
    var client = await _getClient();
    var uri = Uri(
      scheme: 'https',
      host: 'cloud-api.yandex.net',
      path: '/v1/disk/resources',
      queryParameters: {
        'path': folderId ?? 'disk:/',
        'limit': '1000',
      },
    );

    var response = await client.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Error getting folder contents");
    }

    var data = jsonDecode(response.body);
    List<MyFile> files = [];

    for (var item in data["_embedded"]["items"]) {
      files.add(
        MyFile(
          id: item["path"],
          name: item["name"],

          type: item["type"] == "dir" ? Strings.FILE_TYPES_FOLDER
                : _mimeTypes[item["mime_type"]] != null ? _mimeTypes[item["mime_type"]]!.keys.first
                : "Unknown",

          icon: item["type"] == "dir" ? const Icon(Icons.folder)
                : _mimeTypes[item["mime_type"]] != null ? _mimeTypes[item["mime_type"]]!.values.first
                : const Icon(Icons.insert_drive_file),
        )
      );
    }

    return files;
          
  }

  // Download File
  @override
  Future<File> downloadFile(String fileId) async {
    Directory tempDir = await Storage.getTemporaryFolder();

    final fileName = '${Strings.TEMPORARY_FILE_PREFIX}_${Strings.YANDEX_DISK_PREFIX}_${label}_${fileId.replaceAll(':', '_').replaceAll('/', '_')}';
    final file = File('${tempDir.path}/$fileName');

    if (await file.exists()) {
      return file;
    }

    var client = await _getClient();
    var uri = Uri(
      scheme: 'https',
      host: 'cloud-api.yandex.net',
      path: '/v1/disk/resources/download',
      queryParameters: {
        'path': fileId,
      },
    );

    var response = await client.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Error downloading file");
    }

    var downloadUrl = jsonDecode(response.body)["href"];
    var downloadResponse = await client.get(Uri.parse(downloadUrl));

    if (downloadResponse.statusCode != 200) {
      throw Exception("Error downloading file");
    }

    await file.writeAsBytes(downloadResponse.bodyBytes);
    return file;
    
  }

  // Upload File
  @override
  Future<bool> uploadFile({String? folderId, required String filePath}) async {
    var client = await _getClient();
    var file = File(filePath);

    var uri = Uri(
      scheme: 'https',
      host: 'cloud-api.yandex.net',
      path: '/v1/disk/resources/upload',
      queryParameters: {
        'path': folderId == null ? 'disk:/${filePath.split("/").last}'
                : '$folderId/${filePath.split("/").last}',
        'overwrite': 'true',
      },
    );

    var response = await client.get(uri);
    if (response.statusCode != 200) {
      if (kDebugMode) print(response.body.toString());
      throw Exception("Error uploading file");
    }

    var data = jsonDecode(response.body);
    var href = data["href"];

    var uploadResponse = await client.put(
      Uri.parse(href),
      body: await file.readAsBytes(),
    );

    if (uploadResponse.statusCode != 201) {
      throw Exception(uploadResponse.body);
    }

    return true;
    
  }
  
  // Delete File
  @override
Future<bool> deleteFile(String fileId) async {
    var client = await _getClient();
    var uri = Uri(
      scheme: 'https',
      host: 'cloud-api.yandex.net',
      path: '/v1/disk/resources',
      queryParameters: {
        'path': fileId,
        // 'permanently': 'true',
      },
    );

    var response = await client.delete(uri);

    if (response.statusCode != 204) {
      throw Exception("Error deleting file");
    }

    return true;
  }

  @override
  Future<bool> createFolder({required String folderName, String? parentFolderId}) async {
    var client = await _getClient();
    var uri = Uri(
      scheme: 'https',
      host: 'cloud-api.yandex.net',
      path: '/v1/disk/resources',
      queryParameters: {
        'path': parentFolderId == null ? 'disk:/$folderName'
                : 'disk:/$parentFolderId/$folderName',
        'overwrite': 'true',
      },
    );

    var response = await client.put(uri);

    if (response.statusCode != 201) {
      if (kDebugMode) print(response.body.toString());
      throw Exception("Error creating folder");
    }

    return true;
  }

  @override
  Future<bool> deleteFolder(String folderId) {
    return deleteFile(folderId);
  }

  @override
  Future<bool> renameFile(String fileId, String newName) async {
    var newFileId = '${fileId.split('/').sublist(0, fileId.split('/').length - 1).join('/')}/$newName';
    var client = await _getClient();

    // Construct the move request URI
    var uri = Uri(
        scheme: 'https',
        host: 'cloud-api.yandex.net',
        path: '/v1/disk/resources/move',
        queryParameters: {
          "from": fileId,
          "path": newFileId,
          "overwrite": "true"
        }
    );

    // Send the move/rename request
    var response = await client.post(uri);

    // Check if we got an asynchronous response (operation status)
    if (response.statusCode == 202) {
      var operationHref = jsonDecode(response.body)['href'];

      // Poll the operation status
      bool isCompleted = await _pollOperationStatus(operationHref, client);

      if (isCompleted) {
        return true;
      } else {
        throw Exception("Error: File rename operation did not complete successfully.");
      }
    } else if (response.statusCode == 201) {
      // Immediate success response
      return true;
    } else {
      if (kDebugMode) print(response.body.toString());
      throw Exception("Error renaming file");
    }
  }

  // Helper function to poll operation status
  Future<bool> _pollOperationStatus(String operationHref, YandexClient client) async {
    var operationUri = Uri.parse(operationHref);

    while (true) {
      var operationResponse = await client.get(operationUri);
      var operationStatus = jsonDecode(operationResponse.body);

      if (operationStatus['status'] == 'success') {
        return true;
      } else if (operationStatus['status'] == 'failed') {
        return false;
      }

      // Wait for a short period before checking again
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

}