import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teacherapp/modules/Pages/receive_message.dart';
import 'package:teacherapp/modules/Pages/reception.dart';
import 'package:http/http.dart' as http;
import '../../shared/remote/cachehelper.dart';
import 'message_envoie.dart';

class Messangers extends StatefulWidget {
  Messangers({Key key}) : super(key: key);

  @override
  State<Messangers> createState() => _MessangersState();
}

class _MessangersState extends State<Messangers> with SingleTickerProviderStateMixin{




  TabController tabcontroller;
  void initState() {
    tabcontroller  = TabController(length: 3, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          bottom: TabBar(
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.red,
              labelColor:Colors.red,
              controller: tabcontroller,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.message_outlined),
                      SizedBox(width: 4,),
                      Text('إنشاء رسالة',style: TextStyle(
                          fontSize: 13
                      ),),
                    ],
                  ),

                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_outlined),
                      SizedBox(width: 4,),
                      Text('الرسائل الواردة',style: TextStyle(
                        fontSize: 13
                      ),),
                    ],
                  ),

                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_outlined),
                      SizedBox(width: 4,),
                      Text('رسائلي',style: TextStyle(
                          fontSize: 13
                      ),),
                    ],
                  ),

                ),
              ]),
          title:Text('الرسائل',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
        ),
        body:TabBarView(
            controller:tabcontroller,
            children: [
             Message_envoie(),
             Receive_message(),
             Reception(),
            ]
        ),
      ),
    );
  }
}
