import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_album/screen/camera_screen.dart';
import 'package:photo_album/screen/photo_album_screen.dart';
import 'package:photo_album/screen/theme_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> _recentPhotos = [];

  void _navigateToCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CameraScreen()),
    );
  }

  void _navigateToPhotoAlbum() async {
    final selectedPhotos = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PhotoAlbumScreen(onPhotosSelected: _updateRecentPhotos)),
    );

    if (selectedPhotos != null && selectedPhotos is List<String>) {
      _updateRecentPhotos(selectedPhotos);
    }
  }

  void _navigateToThemeScreen() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => themeScreen()),
  );
}

  void _updateRecentPhotos(List<String> photos) {
    setState(() {
      // Keep only the latest four photos in the _recentPhotos list
      _recentPhotos = photos.reversed.take(4).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _navigateToCamera,
                  child: Icon(Icons.camera),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToPhotoAlbum,
                  child: Icon(Icons.photo_album),
                ),
                SizedBox(height: 20),
                Text('Recent Photos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _recentPhotos.length,
                    itemBuilder: (context, index) {
                      final photoPath = _recentPhotos[index];
                      return Image.file(File(photoPath), fit: BoxFit.cover);
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _navigateToThemeScreen,
                  child: Text('Change Theme'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

