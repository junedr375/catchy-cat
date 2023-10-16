import 'package:cloud_firestore/cloud_firestore.dart';

import 'database_helper.dart';

class FirestoreHelper {
  final _firestore = FirebaseFirestore.instance;

  static String collectionName = 'cat_facts';

  Future<void> addDataToCollection(Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).add(data);
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<bool> addMultipleData(
    List<Map<String, dynamic>> data, {
    required String docId,
  }) async {
    final batch = _firestore.batch();

    for (var data in data) {
      final newDocRef = _firestore
          .collection(collectionName)
          .doc(docId)
          .collection('facts')
          .doc();
      batch.set(newDocRef, data);
    }
    try {
      await batch.commit();
      return true;
    } catch (e) {
      print('Error adding batch data to Firestore: $e');
      return false;
    }
  }

  Future<bool> syncDataToFirebase(List<Map<String, dynamic>> data) async {
    try {
      final timeStamp = DateTime.now().toString();

      final isUpdated = await addMultipleData(data, docId: timeStamp);
      return isUpdated;
    } catch (e) {
      print('Error syncing data from local to cloud database: $e');
      return false;
    }
  }
}
