/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 10, 2026
    Developer: Rijab Butt
    ---------------------------------------
    Description: here all custom colors
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinanalyzer/Utils/values/color.dart';

import '../../Utils/Extension/Widget/widget.dart';
import '../../Utils/values/my_images.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.06,
            vertical: Get.height * 0.03,
          ),
          child: Column(
            children: [
              /// Title
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: MyColors.black,
                ),
              ),

              SizedBox(height: Get.height * 0.01),

              /// Profile Image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: Get.width * 0.45,
                    width: Get.width * 0.45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: MyColors.white, width: 5),
                      image: DecorationImage(
                        image: AssetImage(MyImages.FrontImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MyColors.LightLavender,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: MyColors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),

              SizedBox(height: Get.height * 0.02),

              /// Name
              Text(
                "Emily Johnson",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: MyColors.black,
                ),
              ),

              SizedBox(height: Get.height * 0.001),

              /// Email
              Text(
                "emily.j@email.com",
                style: TextStyle(
                  fontSize: 14,
                  color: MyColors.black.withOpacity(0.6),
                ),
              ),

              SizedBox(height: Get.height * 0.02),

              /// Menu Items (EXACT AS IMAGE)
              tile("Edit Profile", Icons.person),
              tile("Skin Analysis", Icons.opacity),
              tile("Beauty Tips", Icons.favorite),
              tile("Notifications", Icons.notifications),
              tile("Settings", Icons.settings),
              tile("Help & Support", Icons.help_outline),

              SizedBox(height: Get.height * 0.03),

              /// Logout
              Container(
                width: double.infinity,
                height: Get.height * 0.05,
                decoration: BoxDecoration(
                  color: MyColors.LightLavender,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
