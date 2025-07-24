import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ad_detail_screen.dart';
import 'package:final_project/models/ad_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<void> markNotificationsAsSeen(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('notifications').get();

    for (final doc in snapshot.docs) {
      final seenBy = List<String>.from(doc['seenBy'] ?? []);
      if (!seenBy.contains(userId)) {
        await doc.reference.update({
          'seenBy': FieldValue.arrayUnion([userId]),
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    markNotificationsAsSeen(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'الإشعارات',
                style: TextStyle(
                    color: primaryColor, fontSize: 18, fontFamily: mainFont),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_forward,
                color: primaryColor,
              ),
            ),
          ],
          foregroundColor: Colors.white,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              return Center(child: Text("لا توجد إشعارات"));

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final adId = data['ad_id'];
                final timestamp = data['timestamp'] as Timestamp?;
                final date = timestamp != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        timestamp.millisecondsSinceEpoch)
                    : null;

                return InkWell(
                  onTap: () async {
                    if (adId != null && adId.toString().isNotEmpty) {
                      final adSnapshot = await FirebaseFirestore.instance
                          .collection('ads')
                          .doc(adId)
                          .get();

                      if (adSnapshot.exists) {
                        final adData = adSnapshot.data()!;
                        final ad = AdModel.fromMap(
                            adSnapshot.data() as Map<String, dynamic>,
                            adSnapshot.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdDetailScreen(ad: ad),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 10, right: 15, left: 15),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notifications, color: primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اعلان جديد ',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontFamily: mainFont,
                                ),
                              ),
                              Text(
                                data['title'] ?? 'بدون عنوان',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 8, 8, 8),
                                  fontFamily: mainFont,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Text(
//   data['body'] ?? 'لا يوجد محتوى',
//   style: TextStyle(
//       fontFamily: mainFont, fontSize: 12),
// ),
                              if (date != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
