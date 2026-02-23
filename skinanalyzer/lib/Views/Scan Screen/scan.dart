/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 09, 2026
    Developer: Rijab Butt
    ---------------------------------------
    Description: here all custom colors
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinanalyzer/Utils/values/my_images.dart';
import '../../Utils/Extension/Widget/widget.dart';
import '../../Utils/values/color.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender, // soft pink
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),

              /// Title
              Text(
                "Analyze Your Skin",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MyColors.black,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "Take a photo or upload an image\nto analyze your skin.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: MyColors.black),
              ),

              // const SizedBox(height: 20),

              /// Image Preview Circle
              Container(
                height: Get.height * 0.62,
                width: Get.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: MyColors.white, width: 6),
                  image: DecorationImage(
                    image: _image != null
                        ? FileImage(_image!)
                        : AssetImage(MyImages.FrontImage) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // const SizedBox(height: 20),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  actionButton(
                    icon: Icons.camera_alt,
                    text: "Take Photo",
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  actionButton(
                    icon: Icons.image,
                    text: "Upload Image",
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Text(
                "Ensure good lighting for best results.",
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
