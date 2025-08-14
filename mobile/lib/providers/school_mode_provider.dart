import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModeProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  String? parentId;

  Map<String, dynamic> schedule = {'enabled': false, 'days': {}};

  void attach(String parentUid) {
    parentId = parentUid;
    _db.collection('schoolSchedules').doc(parentUid).snapshots().listen((snap) {
      if (snap.exists) {
        schedule = snap.data() as Map<String, dynamic>;
      } else {
        schedule = {'enabled': false, 'days': {}};
      }
      notifyListeners();
    });
  }

  Future<void> save(Map<String, dynamic> data) async {
    if (parentId == null) return;
    await _db.collection('schoolSchedules').doc(parentId).set(data, SetOptions(merge: true));
  }
}
