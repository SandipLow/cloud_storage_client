import 'package:cloud_storage_client/models/my_file.dart';
import 'package:cloud_storage_client/res/strings.dart';
import 'package:flutter/material.dart';


class FileExplorer extends StatefulWidget {
  final String? folderId;
  final dynamic providerService;

  const FileExplorer({super.key, required this.providerService, this.folderId});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  List<MyFile> _files = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();

    // Get files in the folder
    widget.providerService.getFolder(folderId: widget.folderId).then((files) {
      setState(() {
        _files = files;
        _isLoading = false;
      });
    });

  }


  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Loading..."),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("File Explorer"),
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (ctx, idx) {
          return ListTile(
            leading: _files[idx].icon,
            title: Text(_files[idx].name),
            onTap: () {

              // Folder
              if (_files[idx].type == Strings.FILE_TYPES_FOLDER) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return FileExplorer(
                      providerService: widget.providerService,
                      folderId: _files[idx].id,
                    );
                  })
                );
              }


            },
          );
        }
      )
    );
  }
}
