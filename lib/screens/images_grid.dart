import 'package:cloud_storage_client/screens/image_viewer.dart';
import 'package:flutter/material.dart';

class ImagesGrid extends StatelessWidget {
  final List<Image> images;

  const ImagesGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images Grid"),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewer(
                    image: images[index],
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                )
              );
            },
            child: Card(
              child: images[index]
            )
          );
        },
      ),
    );
  }
}