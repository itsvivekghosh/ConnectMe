import 'package:ConnectMe/helper/constants.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
  final String imageUrl, titleMessage;
  FullPhoto({Key key, @required this.imageUrl, @required this.titleMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          titleMessage,
          style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(imageUrl: imageUrl),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String imageUrl;
  FullPhotoScreen({Key key, @required this.imageUrl}) : super(key: key);

  @override
  _FullPhotoScreenState createState() => _FullPhotoScreenState();
}

class _FullPhotoScreenState extends State<FullPhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: NetworkImage(widget.imageUrl),
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Constants.currentTheme == 'dark' ? Colors.white60 : Constants.accentColor,
              ),
              value: event == null
                  ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          ),
        ),
      ),
    );
  }
}

