import 'package:cloud_storage_client/screens/file_explorer.dart';
import 'package:cloud_storage_client/screens/home_tab_layout.dart';
import 'package:cloud_storage_client/screens/image_viewer.dart';
import 'package:cloud_storage_client/screens/settings/access_directories.dart';
import 'package:cloud_storage_client/screens/settings/ignore_directories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_storage_client/res/colors.dart';


void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Storage Client',
      themeMode: ThemeMode.system,

      // App Routes
      routes: {
        '/file_explorer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as FileExplorerArgs;
          return FileExplorer(
            folderName: args.folderName,
            providerService: args.providerService,
            folderId: args.folderId,
          );
        },
        'image_viewer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as ImageViewerArgs;
          return ImageViewer(
            title: args.title,
            image: args.image,
            imagePath: args.imagePath,
          );
        },
        '/settings/access_directories': (context) => const AccessDirectories(),
        '/settings/ignore_directories': (context) => const IgnoreDirectories(),
      },

      // Light Theme
      theme: ThemeData(
        scaffoldBackgroundColor: MyColors.light,
        colorScheme: const ColorScheme.light(
          primary: MyColors.primary,
          secondary: MyColors.secondary,
        ),

      ),

      // Dark Theme
      darkTheme: ThemeData(
        scaffoldBackgroundColor: MyColors.dark,
        colorScheme: const ColorScheme.dark(
          primary: MyColors.primary,
          secondary: MyColors.secondary,
        ),
        
      ),

      home: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabLayout();
  }
}

