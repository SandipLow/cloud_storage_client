import 'package:cloud_storage_client/res/assets.dart';
import 'package:cloud_storage_client/res/colors.dart';
import 'package:cloud_storage_client/res/fonts.dart';
import 'package:cloud_storage_client/screens/cloud_storage.dart';
import 'package:cloud_storage_client/screens/local_albums.dart';
import 'package:cloud_storage_client/screens/settings.dart';
import 'package:flutter/material.dart';

class TabContent {
  final Widget tab;
  final Widget content;

  TabContent({
    required this.tab,
    required this.content,
  });
}

List<TabContent> tabs = [
  TabContent(
    tab: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo),
        SizedBox(width: 8),
        Text("Local"),
      ],
    ),
    content: const LocalAlbums(),
  ),
  TabContent(
    tab: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud),
        SizedBox(width: 8),
        Text("Cloud"),
      ],
    ),
    content: const CloudStorage(),
  ),
  TabContent(
    tab: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.settings),
        SizedBox(width: 8),
        Text("Settings"),
      ],
    ),
    content: const SettingsTab(),
  ),
];

class HomeTabLayout extends StatefulWidget {
  const HomeTabLayout({super.key});

  @override
  State<HomeTabLayout> createState() => _HomeTabLayoutState();
}

class _HomeTabLayoutState extends State<HomeTabLayout> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.background(context),
          foregroundColor: MyColors.text(context),
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Image(image: Images.logo_256),
          ),
          title: const Text(
            "cloud_storage_client",
            style: TextStyle(
              fontFamily: Fonts.Lalezar,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person),
            ),
          ],
          bottom: TabBar(
            tabs: tabs.map((tabContent) => Tab(child: tabContent.tab)).toList(),
            labelColor: MyColors.primary,
            unselectedLabelColor: MyColors.secondary,
            indicatorColor: MyColors.primary,
          ),
        ),
        body: TabBarView(
          children: tabs.map((tabContent) => tabContent.content).toList(),
        ),
      ),
    );
  }
}
