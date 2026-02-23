/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 05, 2026
    Developer: Rijab Butt
    ---------------------------------------
    Description: Login Screen
*/
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinanalyzer/Utils/values/my_images.dart';

import '../../Utils/Extension/Widget/widget.dart';
import '../../Utils/values/color.dart';
import '../Bottom Bar/navigation.dart';
import '../Sign Up/signup.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            left: Get.width * 0.05,
            right: Get.width * 0.05,
            bottom: Get.height * 0.05,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.all(Get.width * 0.05),
                  decoration: BoxDecoration(
                    color:  Color(0xFFE6D9FF).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: Get.width * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: Get.height * 0.01),

                      Text(
                        "Welcome back! Please enter your details.",
                        style: TextStyle(
                          fontSize: Get.width * 0.035,
                          color: Colors.grey[700],
                        ),
                      ),

                      SizedBox(height: Get.height * 0.025),

                      inputField(
                        icon: Icons.email_outlined,
                        hint: "Enter your email",
                      ),

                      SizedBox(height: Get.height * 0.015),

                      inputField(
                        icon: Icons.lock_outline,
                        hint: "Enter your password",
                        isPassword: true,
                      ),

                      SizedBox(height: Get.height * 0.01),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontSize: Get.width * 0.032,
                            color: MyColors.DeepPurple,
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.02),

                      InkWell(
                        onTap: (){
                          Get.off(() => Bottom_bar());
                        },
                        child: Container(
                          width: Get.width,
                          height: Get.height * 0.05,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD6B4FC), Color(0xFFB388FF)],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                color: MyColors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.02),
                      Center(
                        child: InkWell(
                          onTap: () {
                            Get.off(() => SignUpScreen());
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: MyColors.grayscale60,
                                fontSize: Get.width * 0.035,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(
                                    color: MyColors.DeepPurple,
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