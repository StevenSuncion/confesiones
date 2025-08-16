import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class ConfessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> sendTextConfession(String fromUserId, String toUserId, String text) async {
    final confession = ConfessionModel(
      id: _firestore.collection('confessions').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      textContent: text,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('confessions').doc(confession.id).set(confession.toMap());
  }

  Stream<List<ConfessionModel>> getConfessionsForUser(String userId) {
    return _firestore
        .collection('confessions')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConfessionModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> revealConfession(String confessionId) async {
    await _firestore.collection('confessions').doc(confessionId).update({
      'isRevealed': true,
    });
  }
}