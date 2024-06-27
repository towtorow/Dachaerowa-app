import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoDetailPage extends StatefulWidget {
  var imageUrls = [];
  final int initialIndex;

  PhotoDetailPage({Key? key, required this.imageUrls, required this.initialIndex}) : super(key: key);

  @override
  _PhotoDetailPagesState createState() => _PhotoDetailPagesState();
}

class _PhotoDetailPagesState extends State<PhotoDetailPage> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1} / ${widget.imageUrls.length}'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]["imageUrl"]),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrls[index]["imageUrl"]),
          );
        },
        pageController: PageController(initialPage: currentIndex),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
