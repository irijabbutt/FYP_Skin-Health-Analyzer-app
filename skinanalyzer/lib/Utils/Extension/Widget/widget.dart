/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 05, 2026
    Developer: Rijab Butt
    ---------------------------------------
    Description: Widgets
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinanalyzer/Utils/values/color.dart';

/// Reusable Input Field
Widget inputField({
  required IconData icon,
  required String hint,
  bool isPassword = false,
}) {
  return Container(
    height: Get.height * 0.055,
    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
    decoration: BoxDecoration(
      color: MyColors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Icon(icon, color: MyColors.grayscale60),
        SizedBox(width: Get.width * 0.03),
        Expanded(
          child: TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
            ),
          ),
        ),
        if (isPassword)
          const Icon(Icons.visibility_off, color: MyColors.grayscale60),
      ],
    ),
  );
}

Widget summaryCard(String title, String subtitle, String img) {
  return Expanded(
    child: Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Image.asset(img),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

Widget tipsCard(String title, String subtitle, String image) {
  return Container(
    margin: EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: Image.asset(
            image,
            height: 120,
            width: 160,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget tile(String title, IconData icon) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    height: Get.height * 0.05,
    decoration: BoxDecoration(
      color: MyColors.LightLavender,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: MyColors.LightLavender,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: MyColors.black,
            ),
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16),
      ],
    ),
  );
}


Widget actionButton({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 140,
      height: 90,
      decoration: BoxDecoration(
        color: MyColors.LightLavender,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 28),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget topPill({
  required IconData icon,
  required Color iconColor,
  required String number,
  required String label,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$number ",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget progressCard({
  required String title,
  required int value,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F2F2F),
              ),
            ),
            const Spacer(),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor:
            const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      ],
    ),
  );
}
