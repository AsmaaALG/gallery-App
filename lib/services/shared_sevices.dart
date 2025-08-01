import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';


class SharedSevices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   void launchMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'لا يمكن فتح الرابط: $url';
    }
  }

   Future<String> fetchCityName(String cityId) async {
    final doc =
        await FirebaseFirestore.instance.collection('city').doc(cityId).get();
    return doc.exists ? doc.data()!['name'] ?? 'غير معروف' : 'غير معروف';
  }

  Future<String> fetchCompanyName(String companyId) async {
    final doc = await FirebaseFirestore.instance
        .collection('company')
        .doc(companyId)
        .get();
    return doc.exists ? doc.data()!['name'] ?? 'غير معروف' : 'غير معروف';
  }

  
}
