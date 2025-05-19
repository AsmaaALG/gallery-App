import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;
  final Color iconColor;
  final VoidCallback? onPressed; //

  const SocialButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
    required this.textColor,
    required this.iconColor,
    this.onPressed, //
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ✅ استبدال Container بـ GestureDetector لتفعيل onPressed
      onTap: onPressed, // ✅ تنفيذ الدالة عند الضغط
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: iconColor),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
