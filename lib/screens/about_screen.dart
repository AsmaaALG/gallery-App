import 'package:final_project/constants.dart';
import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: primaryColor,
            )),
        title: Text(
          "عن التطبيق",
          style: TextStyle(
              fontFamily: mainFont, color: primaryColor, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // شعار التطبيق
            Container(
                margin: EdgeInsets.only(bottom: 5),
                width: 220,
                height: 220,
                child: Image.asset('images/logo.png')),

            // نص نبذة عن التطبيق
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'تطبيق يهدف إلى إدارة المعارض بشكل رقمي وفعّال، من خلال تسهيل تسجيل العارضين والزوار، '
                'عرض معلومات المعارض، وتوفير تحديثات فورية، مما يعزز تجربة المستخدم ويطور أداء الفعاليات.',
                style: TextStyle(
                  fontFamily: mainFont,
                  fontSize: 16,
                  height: 1.6,
                  color: const Color.fromARGB(255, 47, 45, 45),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
