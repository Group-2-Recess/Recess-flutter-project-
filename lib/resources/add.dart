import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required String names,
    required String organisationName,
    required String location,
    required Uint8List file,
  }) async {
    String resp = "Some error occurred";
    try {
      if (names.isNotEmpty && organisationName.isNotEmpty && location.isNotEmpty) {
        String imageUrl = await uploadImageToStorage("profileImage", file);
        await _firestore.collection("UserProfile").add({
          'name': names,
          'organisationName': organisationName,
          'location': location,
          'imagelink': imageUrl,
        });
        resp = "Success";
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}
