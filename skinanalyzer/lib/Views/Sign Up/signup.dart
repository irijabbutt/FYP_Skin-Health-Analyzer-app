/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 05, 2026
    Developer: Rijab Butt 
    ---------------------------------------
    Description: here all custom colors
*/
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinanalyzer/Utils/values/my_images.dart';
import 'package:skinanalyzer/Views/Log%20In/login.dart';

import '../../Utils/Extension/Widget/widget.dart';
import '../../Utils/values/color.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: Image.asset(
              MyImages.Picture,
              fit: BoxFit.cover,
            ),
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

          /// Glass Card
          Positioned(
            left: Get.width * 0.05,
            right: Get.width * 0.05,
            bottom: Get.height * 0.04,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.all(Get.width * 0.05),
                  decoration: BoxDecoration(
                    color:  Color(0xFFE6D9FF).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: Get.width * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: Get.height * 0.008),

                      Text(
                        "Create your account to get personalized skin care",
                        style: TextStyle(
                          fontSize: Get.width * 0.035,
                          color: Colors.grey[700],
                        ),
                      ),

                      SizedBox(height: Get.height * 0.025),

                      inputField(
                        icon: Icons.person_outline,
                        hint: "Enter your full name",
                      ),

                      SizedBox(height: Get.height * 0.015),

                      inputField(
                        icon: Icons.calendar_today_outlined,
                        hint: "Enter your Age",
                      ),

                      SizedBox(height: Get.height * 0.015),

                      inputField(
                        icon: Icons.wc_outlined,
                        hint: "Gender",
                      ),

                      SizedBox(height: Get.height * 0.015),

                      inputField(
                        icon: Icons.email_outlined,
                        hint: "Enter your email",
                      ),

                      SizedBox(height: Get.height * 0.015),

                      inputField(
                        icon: Icons.lock_outline,
                        hint: "Create password",
                        isPassword: true,
                      ),

                      SizedBox(height: Get.height * 0.015),

                      inputField(
                        icon: Icons.lock_outline,
                        hint: "Confirm password",
                        isPassword: true,
                      ),

                      SizedBox(height: Get.height * 0.02),

                      /// Terms
                      Row(
                        children: [
                          Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFF673AB7),
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Color(0xFF673AB7),
                            ),
                          ),
                          SizedBox(width: Get.width * 0.02),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: "I agree to the ",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: Get.width * 0.032,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Terms & Privacy Policy",
                                    style: TextStyle(
                                      color: Color(0xFF673AB7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Get.height * 0.025),

                      /// Create Account Button
                      Container(
                        height: Get.height * 0.05,
                        width: Get.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE6D9FF), Color(0xFF673AB7)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.02),

                      /// Login Text
                      Center(
                        child: InkWell(onTap: (){
                          Get.off(() => LoginScreen());
                        },
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: Get.width * 0.035,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Log In",
                                  style: TextStyle(
                                    color: Color(0xFF673AB7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
