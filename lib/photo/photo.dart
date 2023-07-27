class PhotoInfo {
  String photoPath;
  String description;
  String location;
  String dateTime;
  String folderName;

  PhotoInfo({
    required this.photoPath,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.folderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'photoPath': photoPath,
      'description': description,
      'location': location,
      'dateTime': dateTime,
      'folderName': folderName,
    };
  }
}
