# Adding a new cloud Drive service guide

Adding new cloud storage service, you need to :-

## 1. Add entry in the Drive Storage
Go to `lib/services/storage.dart > getDrives()` and add entry in the function as like similar drives.

## 2. Add entry in the Storage class
Add relevant functions to manage access credentials such as tokens in `lib/services/storage.dart` which should contain :

```dart
class Storage {
  // ... Existing Code

  // Save Credentials for accessing service apis
  Future saveCredentials(String email, AccessToken accessToken, String? refreshToken);
  // Get Credentials for accessing service apis
  Future<Map<String, String>> getCredentials(String email);
  // Remove Credentials for accessing service apis
  Future removeCredentials(String email);
}
```

## 3. Create a service class
Add a service class in `lib/services/new_drive.dart` which should contain : 

```dart
class NewDrive { 
    // storage instance to manage data in flutter storage
    final _storage = NewDriveStorage();
    // email / username in the provider
    late String label;
    // reference in storage
    String prefix = "new_drive";
    // Icon of the service
    Icon icon = const Icon(Icons.provider);

    // Create drive account
    static Future<NewDrive> addAccount() 
    // http client
    Future<http.Client> _getClient() 
    // Get folder
    Future<List<MyFile>> getFolder({String? folderId})
    // Download File
    Future downloadFile(String fileId) 
    // upload file
    Future uploadFile(String filePath, String? folderId, String? fileName)  
}

```

## 4. Implement service UI accordingly
In `lib/screens/cloud_storage.dart` add a `ListTile()` entry for your service provider add and explore action