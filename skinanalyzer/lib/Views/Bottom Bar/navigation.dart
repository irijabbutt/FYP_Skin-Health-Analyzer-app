/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 08, 2026
    Developer: Rijab Butt
    ---------------------------------------
    Description: Navigation Screen
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utils/values/color.dart';
import '../Home Screen/homescreen.dart';
import '../Profile/profile.dart';
import '../Scan Screen/scan.dart';

// ignore: camel_case_types
class Bottom_bar extends StatefulWidget {
  const Bottom_bar({super.key});

  @override
  State<Bottom_bar> createState() => _Bottom_barState();
}

// ignore: camel_case_types
class _Bottom_barState extends State<Bottom_bar> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: MyColors.black,
  );
  static final List<Widget> _widgetOptions = <Widget>[
    SkinHomeScreen(),
    ScanScreen(),
    ProfileScreen(),
    Text('Index 0: Home', style: optionStyle),
    Text('Index 1: Scan', style: optionStyle),
    Text('Index 2: Profile', style: optionStyle),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        padding: EdgeInsets.zero,
        // shape: CircularNotchedRectangle(),
        color: MyColors.LightLightLavender,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: Get.height * 0.7,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      updateTabSelection(0, "Home");
                    },
                    iconSize: 27.0,
                    icon: Icon(
                      _selectedIndex == 0
                          ? Icons.home_outlined
                          : Icons.home_filled,
                      color: _selectedIndex == 0
                          ? MyColors.PastelRose
                          : MyColors.black,
                    ),
                  ),
                  Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedIndex == 0
                          ? MyColors.black
                          : MyColors.black,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      updateTabSelection(1, "Scan");
                    },
                    iconSize: 27.0,
                    icon: Icon(
                      _selectedIndex == 1
                          ? Icons.center_focus_weak
                          : Icons.center_focus_strong,
                      color: _selectedIndex == 1
                          ? MyColors.PastelRose
                          : MyColors.black,
                    ),
                  ),
                  Text(
                    "Scan",
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedIndex == 1
                          ? MyColors.black
                          : MyColors.black,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      updateTabSelection(2, "Profile");
                    },
                    iconSize: 27.0,
                    icon: Icon(
                      _selectedIndex == 2
                          ? Icons.person_2_outlined
                          : Icons.person,
                      color: _selectedIndex == 2
                          ? MyColors.PastelRose
                          : MyColors.black,
                    ),
                  ),
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedIndex == 2
                          ? MyColors.black
                          : MyColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateTabSelection(int index, String tabName) {
    setState(() {
      _selectedIndex = index;
    });
    print("Tab selected: $tabName");
  }
}
