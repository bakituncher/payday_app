/// Firebase implementation of MonthlySummaryRepository
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/repositories/monthly_summary_repository.dart';

class FirebaseMonthlySummaryRepository implements MonthlySummaryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('monthly_summaries');
  }

  @override
  Future<MonthlySummary?> getSummaryForMonth(String userId, DateTime month) async {
    // Format month as YYYY-MM or store as timestamp.
    // Assuming the ID is generated or we query by month/year fields.
    // Let's assume we store month/year in the document.
    final snapshot = await _getCollection(userId)
        .where('month', isEqualTo: month.month)
        .where('year', isEqualTo: month.year)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return MonthlySummary.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  @override
  Future<void> saveSummary(MonthlySummary summary) async {
    // Use a composite key or let Firestore generate ID.
    // Ideally ID is YYYY-MM
    final id = '${summary.year}-${summary.month}';
    await _getCollection(summary.userId).doc(id).set(summary.toJson());
  }

  @override
  Future<List<MonthlySummary>> getSummariesForYear(String userId, int year) async {
    final snapshot = await _getCollection(userId)
        .where('year', isEqualTo: year)
        .get();

    return snapshot.docs.map((d) => MonthlySummary.fromJson(d.data())).toList();
  }
}
