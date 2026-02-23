/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 05, 2026
    Developer: Rijab Butt
    ---------------------------------------
    Description: Get Started Screen
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinanalyzer/Utils/values/my_images.dart';

import '../../Utils/values/color.dart';
import '../Log In/login.dart';

class SkinDiscoverScreen extends StatelessWidget {
  const SkinDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: Image.asset(MyImages.Picture, fit: BoxFit.cover),
          ),
          Positioned(
            left: Get.width * 0.10,
            top: Get.height * 0.05,
            child: Text(
              "Skin Health Analyzer",
              style: TextStyle(
                fontSize: 30,
                color: MyColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            left: Get.width * 0.04,
            right: Get.width * 0.04,
            bottom: Get.height * 0.03,
            child: Container(
              padding: EdgeInsets.all(Get.width * 0.05),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Discover\nWhat Your\nSkin Truly Needs",
                    style: TextStyle(
                      fontSize: Get.width * 0.075,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: Get.height * 0.02),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6D9FF),
                      foregroundColor: MyColors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: Get.width * 0.05,
                        vertical: Get.height * 0.012,
                      ),
                    ),
                    onPressed: () {
                      Get.off(() => LoginScreen());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: Get.width * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: Get.width * 0.015),
                        Icon(Icons.arrow_forward, size: Get.width * 0.045),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
