import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fp2/utils/file_utils.dart';
import 'package:fp2/utils/firebase.dart';
import 'package:path_provider/path_provider.dart';

abstract class Service {
  Future<String> getCacheFilePath(String filename) async {
    Directory tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/$filename';
  }

  Future<void> example() async {
    String filePath = await getCacheFilePath('image_cropper_1721794694849.jpg');
    File file = File(filePath);

    if (await file.exists()) {
      // File exists, you can read or move it
      print('File found at $filePath');
    } else {
      print('File does not exist.');
    }
  }

  Future<String?> uploadImage(Reference ref, File file) async {
    try {
      if (!file.existsSync()) {
        print('File does not exist');
        return null;
      }

      example();

      print('Starting image upload...');
      String ext = FileUtils.getFileExtension(file);
      print('extension=$ext');
      Reference storageReference = ref.child("${uuid.v4()}.$ext");
      print('Storage reference created: ${storageReference.fullPath}');

      UploadTask uploadTask = storageReference.putFile(file);
      print('File upload task initiated...');

      // Monitor the upload task for completion
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Task state: ${snapshot.state}'); // e.g. "running", "paused", "success"
        print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      }, onError: (e) {
        // Handle errors
        print('Upload error: $e');
      });

      // Wait for the upload task to complete
      TaskSnapshot taskSnapshot = await uploadTask;
      if (taskSnapshot.state == TaskState.success) {
        // Get the download URL after the upload is complete
        String downloadUrl = await storageReference.getDownloadURL();
        print('Download URL obtained: $downloadUrl');
        return downloadUrl;
      } else {
        print('Upload failed, task state: ${taskSnapshot.state}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
