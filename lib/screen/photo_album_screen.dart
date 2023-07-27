import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:photo_album/photo/photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_album/screen/photo_info_screen.dart';

class PhotoAlbumScreen extends StatefulWidget {
  final Function(List<String>)? onPhotosSelected; 

  const PhotoAlbumScreen({this.onPhotosSelected});

  @override
  _PhotoAlbumScreenState createState() => _PhotoAlbumScreenState();
}

class _PhotoAlbumScreenState extends State<PhotoAlbumScreen> {
  List<String> _photoPaths = [];
  List<String> _photoDescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadPhotosFromStorage();
  }

  Future<void> _loadPhotosFromStorage() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String photoDir = '${appDir.path}/photos';
      final List<FileSystemEntity> files = Directory(photoDir).listSync();
      final List<String> photoPaths = files.map((file) => file.path).toList();
      final List<String> photoDescriptions = List<String>.filled(photoPaths.length, '');
      setState(() {
        _photoPaths = photoPaths;
        _photoDescriptions = photoDescriptions;
      });
    } catch (e) {
      print('Error loading photos from storage: $e');
    }
  }

  Future<void> showAlertDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this photo?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deletePhoto(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePhoto(int index) {
  setState(() {
    String photoPathToDelete = _photoPaths[index];
    File photoFileToDelete = File(photoPathToDelete);

    try {
      photoFileToDelete.deleteSync();
      print('Photo file deleted successfully');
    } catch (e) {
      print('Error deleting photo file: $e');
    }

    String photoDescriptionToDelete = _photoDescriptions[index];
    FirebaseFirestore.instance.collection('photos').where('photoPath', isEqualTo: photoPathToDelete).where('description', isEqualTo: photoDescriptionToDelete).get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        FirebaseFirestore.instance.collection('photos').doc(docId).delete();
      }
    }).catchError((error) {
      print('Error fetching existing data: $error');
    });

    setState(() {
      List<String> updatedPaths = List.from(_photoPaths);
      List<String> updatedDescriptions = List.from(_photoDescriptions);

      updatedPaths.removeAt(index);
      updatedDescriptions.removeAt(index);

      _photoPaths = updatedPaths;
      _photoDescriptions = updatedDescriptions;
      });
  });
}

  Future<void> _showEditDescriptionDialog(BuildContext context, int index) async {
    final TextEditingController descriptionController = TextEditingController();
    descriptionController.text = _photoDescriptions[index];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Description'),
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _updatePhotoDescription(index, descriptionController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updatePhotoDescription(int index, String description) {
    setState(() {
      _photoDescriptions[index] = description;
    });

    final photoPath = _photoPaths[index];
    FirebaseFirestore.instance.collection('photos').where('photoPath', isEqualTo: photoPath).get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        final existingData = snapshot.docs.first.data();
      
      final updatedData = {
        ...existingData,
        'description': description,
      };
      
      FirebaseFirestore.instance.collection('photos').doc(docId).update(updatedData);
    }
  }).catchError((error) {
    print('Error fetching existing data: $error');
  });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Album')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _photoPaths.length,
        itemBuilder: (context, index) {
          final photoPath = _photoPaths[index];
          return GestureDetector(
            onTap: () async{
               final photoInfo = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhotoInfoScreen(photoPath: photoPath)),
               );
                 if (photoInfo != null && photoInfo is PhotoInfo) {
                FirebaseFirestore.instance.collection('photos').add(photoInfo.toMap());
            }
            },
            onLongPress: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Description'),
                        onTap: () {
                          Navigator.pop(context);
                          _showEditDescriptionDialog(context, index);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete Photo'),
                        onTap: () {
                          Navigator.pop(context);
                          showAlertDialog(context, index);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Stack(
              children: [
                Image.file(File(photoPath), fit: BoxFit.cover),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Text(
                    'Photo ${index + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),

          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.onPhotosSelected != null) {
            widget.onPhotosSelected!(_photoPaths);
          }
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
