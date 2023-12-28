import 'package:cloud_storage_client/res/assets.dart';
import 'package:cloud_storage_client/screens/file_explorer.dart';
import 'package:cloud_storage_client/services/g_drive.dart';
import 'package:cloud_storage_client/services/storage.dart';
import 'package:cloud_storage_client/services/yandex.dart';
import 'package:flutter/material.dart';

class CloudStorage extends StatefulWidget {
  const CloudStorage({super.key});

  @override
  State<CloudStorage> createState() => _CloudStorageState();
}

class _CloudStorageState extends State<CloudStorage> {
  final Storage _storage = Storage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _storage.getDrives(),
      builder: (context, snapshot) {

        if (snapshot.hasData && snapshot.data != null) {
          return ListView.builder(
            itemCount: snapshot.data!.length + 1,
            itemBuilder: (context, index) {

              // Add Account Tile Element
              if (index == snapshot.data!.length) {
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("Add Account"),
                  onTap: () async {
                    // Open a modal
                    var result = await showModalBottomSheet(
                      context: context,
                      builder: (context) => const AddAccountModal()
                    );
                  },
                );
              }

              // Drive Tile Element
              return ListTile(
                leading: snapshot.data![index].icon,
                title: Text(snapshot.data![index].label),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return FileExplorer(
                        providerService: snapshot.data![index].providerService,
                      );
                    })
                  );
                },
              );
            },
          );
        }

        else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}


class AddAccountModal extends StatefulWidget {
  const AddAccountModal({super.key});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Add Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Google Drive
          ListTile(
            leading: const Image(image: Images.googleDrive, width: 24, height: 24),
            title: const Text("Google Drive"),
            onTap: () {
              GoogleDrive.addAccount().then((GoogleDrive gDrive) {
                Navigator.pop(context);
              });
            },
          ),

          // Yandex Disk
          ListTile(
            leading: const Image(image: Images.yandex, width: 24, height: 24),
            title: const Text("Yandex Disk"),
            onTap: () async {
              YandexDisk.addAccount().then((YandexDisk yandex) {
                Navigator.pop(context);
              });
            },
          ),

        ],
      ),
    );
  }
}
