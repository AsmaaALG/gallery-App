import 'package:flutter/material.dart';
import 'package:final_project/constants.dart';

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected
                ? secondaryColor
                : Colors.white, // لون الخلفية عند التحديد
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // شكل الزر
            ),
            side: BorderSide(
              color: isSelected ? Colors.black12 : Colors.grey, // لون الحواف
              width: 1.0, // عرض الحواف
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700], // لون النص
            ),
          ),
        ),
      ),
    );
  }
}
