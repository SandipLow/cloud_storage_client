import 'dart:io';

import 'package:cloud_storage_client/services/local_albums.dart';
import 'package:flutter/material.dart';


/// A widget that displays a grid of images.
///
/// This widget takes in a list of [Image] objects or a list of [File] objects and displays them in a grid.
/// If both [images] and [imageFiles] are provided, [images] will be used.
///
/// The [handleTapImage] function is called when an image in the grid is tapped.
/// It should take three arguments:
/// - [title] the title of the grid.
/// - [Image] the image that was tapped.
/// - [int] the index of the image in the list.
/// - [BuildContext] the build context of the widget.
///
/// ```dart
/// ImagesGrid(
///   images: [Image.network('https://example.com/image1.png'), Image.network('https://example.com/image2.png')],
///   handleTapImage: (image, index, context) {
///     print('Tapped image $index');
///   },
/// );
/// ```
class ImagesGrid extends StatelessWidget {
  /// The title of the grid.
  final String title;

  /// A list of [Image] objects to display in the grid.
  final List<Image>? images;

  /// A list of [File] objects to display in the grid.
  final List<File>? imageFiles;

  /// A function that is called when an image in the grid is tapped.
  final Function(Image, int, BuildContext) handleTapImage;

  /// Creates an instance of [ImagesGrid].
  ///
  /// If both [images] and [imageFiles] are provided, [images] will be used.
  const ImagesGrid({Key? key, this.title = "Images Grid", this.images, this.imageFiles, required this.handleTapImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (screenWidth < 720) ? 2 : (screenWidth < 1080) ? 3 : 4,
          childAspectRatio: 1,
        ),
        itemCount: images!=null ? images?.length
                    : imageFiles!=null ? imageFiles?.length
                    : 0,
        itemBuilder: (context, index) {

          if (images!=null) {
            return GestureDetector(
              onTap: () => handleTapImage(images![index], index, context),
              child: Card(
                borderOnForeground: true,
                elevation: 0,
                child: images![index]
              )
            );
          }

          else if (imageFiles!=null) {
            return GestureDetector(
              onTap: () => handleTapImage(Image.file(imageFiles![index]), index, context),
              child: Card(
                borderOnForeground: true,
                elevation: 0,
                child: FutureBuilder(
                  future: LocalAlbumService.getCompressedImage(imageFiles![index].path),
                  builder: (context, snapshot) {
                    
                    if (snapshot.hasData) {
                      return Image.file(snapshot.data as File);
                    }

                    else {
                      return Container(
                        color: Colors.grey[300],
                      );
                    }

                  },
                )
              )
            );
          }

          return GestureDetector(
            onTap: () {},
            child: Card(
              borderOnForeground: true,
              elevation: 0,
              child: Container(
                color: Colors.grey[300],
              )
            )
          );
        },
      ),
    );
  }
}