import 'package:cloud_storage_client/res/assets.dart';
import 'package:cloud_storage_client/res/colors.dart';
import 'package:cloud_storage_client/res/fonts.dart';
import 'package:cloud_storage_client/screens/cloud_storage.dart';
import 'package:flutter/material.dart';



class Tab {
  final BottomNavigationBarItem bottomNavigationBarItem;
  final Widget content;

  Tab({
    required this.bottomNavigationBarItem,
    required this.content
  });
}


List<Tab> tabs = [
  Tab(
    bottomNavigationBarItem: const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Feeds",
    ),
    content: const Center(child: Text("Feeds")),
  ),
  Tab(
    bottomNavigationBarItem: const BottomNavigationBarItem(
      icon: Icon(Icons.photo),
      label: "Photos",
    ),
    content: const Center(child: Text("Photos")),
  ),
  Tab(
    bottomNavigationBarItem: const BottomNavigationBarItem(
      icon: Icon(Icons.cloud),
      label: "Cloud Storages",
    ),
    content: const CloudStorage(),
  ),
  Tab(
    bottomNavigationBarItem: const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: "Settings"
    ),
    content: const Center(child: Text("Settings")),
  ),
];


class HomeTabLayout extends StatefulWidget {
  const HomeTabLayout({super.key});

  @override
  State<HomeTabLayout> createState() => _HomeTabLayoutState();
}

class _HomeTabLayoutState extends State<HomeTabLayout> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          )
        ),
        actions: [
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.person)
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: tabs.map((tab) => tab.bottomNavigationBarItem).toList(),
        unselectedItemColor: MyColors.secondary,
        selectedItemColor: MyColors.primary,
        currentIndex: _selectedTabIndex,
        onTap: (int index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: tabs.map((tab) => tab.content).toList(),
      ),
    );
  }
}
