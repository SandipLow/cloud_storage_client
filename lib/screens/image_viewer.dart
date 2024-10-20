import 'package:flutter/material.dart';

/// A widget that displays an image along with a title and a set of actions.
///
/// This widget takes in a [title] which is displayed in the AppBar, an [Image] object to display,
/// and a list of [IconButton] objects that are displayed in a row at the bottom of the screen.
///
/// The [title] defaults to "Image Viewer" if not provided.
/// The [actions] defaults to an empty list if not provided.
///
/// ```dart
/// ImageViewer(
///   title: 'My Image',
///   image: Image.network('https://example.com/image.png'),
///   actions: [
///     IconButton(
///       icon: Icon(Icons.favorite),
///       onPressed: () {
///         print('Favorite button pressed');
///       },
///     ),
///     IconButton(
///       icon: Icon(Icons.share),
///       onPressed: () {
///         print('Share button pressed');
///       },
///     ),
///   ],
/// );
/// ```
class ImageViewer extends StatelessWidget {
  /// The title displayed in the AppBar.
  final String title;

  /// The image to display.
  final Image image;

  /// The list of action buttons to display at the bottom of the screen.
  final List<IconButton> actions;

  /// Creates an instance of [ImageViewer].
  ///
  /// The [title] defaults to "Image Viewer" if not provided.
  /// The [actions] defaults to an empty list if not provided.
  const ImageViewer({Key? key, this.title = "Image Viewer", required this.image, this.actions = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
