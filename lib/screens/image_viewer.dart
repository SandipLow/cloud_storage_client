import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final Image image;
  final List<IconButton> actions;

  const ImageViewer({super.key, required this.image, this.actions=const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Viewer"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: image,
            ),
          ),

          // actions bar for the image
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.black.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions,
            ),
          ),
        ],
      ),
    );
  }
}
