import 'package:flutter/material.dart';
import 'package:teacherapp/modules/Pages/absence.dart';
import 'package:teacherapp/modules/Pages/policy_page.dart';
import '../../shared/remote/cachehelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../modules/Pages/profile.dart';
import '../../modules/Pages/publicitions.dart';
import '../../modules/Pages/messangers.dart';
import 'package:url_launcher/url_launcher.dart';
class HomeScreen extends StatefulWidget {
   HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String access_token = Cachehelper.getData(key: "token");

 int  SelectedIndex = 0;
   @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget>screens=[
      Publications(),
      Messangers(),
      Absences(),
      Profile(),
      PolicyPage(),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            showSelectedLabels: true,
            selectedItemColor:Colors.red,
            type: BottomNavigationBarType.fixed,
            onTap: (index){
              setState(() {
                SelectedIndex = index;
                if(index==4){
                  launch('https://api.sofia-sahara.com/pdf.pdf');
                }
              });
            },
            currentIndex:SelectedIndex,
            items: [
              BottomNavigationBarItem(icon:Icon(Icons.ads_click), label: 'اعلانات'),
              BottomNavigationBarItem(icon:Icon(Icons.message_outlined), label: 'الرسائل'),
              BottomNavigationBarItem(icon:Icon(Icons.inventory_outlined),label: 'الغياب'),
              BottomNavigationBarItem(icon:Icon(Icons.person_2_outlined),label: 'حسابي'),
              BottomNavigationBarItem(icon:Icon(Icons.balance),label: 'القانون الداخلي'),
             ]),
        backgroundColor:Colors.white,
        body:screens[SelectedIndex]
      ),
    );
  }
}
