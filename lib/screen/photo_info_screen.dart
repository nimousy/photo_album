import 'package:flutter/material.dart';
import 'package:photo_album/photo/photo.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class PhotoInfoScreen extends StatefulWidget {
  final String photoPath;

  const PhotoInfoScreen({required this.photoPath});

  @override
  _PhotoInfoScreenState createState() => _PhotoInfoScreenState();
}

class _PhotoInfoScreenState extends State<PhotoInfoScreen> {
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _dateTimeController = TextEditingController();
  TextEditingController _folderNameController = TextEditingController();

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _locationController.text =
          "Lat: ${position.latitude}, Lng: ${position.longitude}";
    } catch (e) {
      print("Error getting location: $e");
      _locationController.text = "Unable to get location";
    }
  }

  void _savePhotoInfo() {
    final photoInfo = PhotoInfo(
      photoPath: widget.photoPath,
      description: _descriptionController.text,
      location: _locationController.text,
      dateTime: _dateTimeController.text,
      folderName: _folderNameController.text,
    );

     FirebaseFirestore.instance.collection('photos').add(photoInfo.toMap());

    Navigator.pop(context, photoInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Info')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.file(File(widget.photoPath), fit: BoxFit.cover, height: 200),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                suffixIcon: IconButton(  
                  icon: Icon(Icons.location_on), 
                  onPressed: _getLocation,
                ),
                ),
               ),
            TextField(
              controller: _dateTimeController,
              decoration: InputDecoration(labelText: 'Date Time'),
            ),
            TextField(
              controller: _folderNameController,
              decoration: InputDecoration(labelText: 'Folder Name'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePhotoInfo,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
