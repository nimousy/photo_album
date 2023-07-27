import 'package:photo_album/screen/photo_album_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFrontCamera = false; 

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final initialCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
    );
    _controller = CameraController(
      initialCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture; 
    if (!mounted) return; 
    setState(() {}); 
  }

  Future<void> _toggleCamera() async {
    if (_controller != null) {
      await _controller.dispose();
    }

    _isFrontCamera = !_isFrontCamera; 

    await _initializeCamera(); 
  }

  Future<void> _takePhoto() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String photoDir = '${appDir.path}/photos';
      await Directory(photoDir).create(recursive: true);
      final String filePath = '$photoDir/${DateTime.now().millisecondsSinceEpoch}.png';

      XFile pictureFile = await _controller.takePicture();

      File(pictureFile.path).copy(filePath);

      Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoAlbumScreen()));
    } catch (e) {
      print('Error while taking a photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializeControllerFuture == null || _controller == null || !_controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Camera')),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Camera'),
          actions: [
            IconButton(
              icon: Icon(Icons.switch_camera),
              onPressed: _toggleCamera,
            ),
          ],
        ),
        body: CameraPreview(_controller),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed: _takePhoto,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
