import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:teacherapp/shared/components/components.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;

import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';

class Receive_message extends StatefulWidget {
  const Receive_message({Key key}) : super(key: key);

  @override
  State<Receive_message> createState() => _Receive_messageState();
}

class _Receive_messageState extends State<Receive_message> {
  TextEditingController Titrecontroller = TextEditingController();
  TextEditingController Messagecontroller = TextEditingController();
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  String access_token = Cachehelper.getData(key: "token");
  bool isloading = true;
  List messagesReceive = [];
  Future getMessages()async{
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/api/v1/user/professeur/messages?filter[user_messages]=receive'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        messagesReceive = data['data'];
        print(data);
        setState(() {
          isloading = true;
        });
      }else{
        var data = json.decode(value.body);
        setState(() {
          print(data);
          isloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }
  @override
  void initState() {
    getMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isloading? messagesReceive.length>0?SingleChildScrollView(
      physics:BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          height(20),
          ListView.separated(
              shrinkWrap: true,
              physics:NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
                String inputDate = "${messagesReceive[index]['created_at']}";
                DateTime dateTime = DateTime.parse(inputDate);
                String formattedDate = DateFormat('HH:mm / d MMM').format(dateTime);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child:Card(
                        elevation: 2,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Row(
                                      children:[
                                        CircleAvatar(
                                          backgroundImage: NetworkImage("${messagesReceive[index]['sendable']['avatar']}"),
                                        ),
                                        width(8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            height(5),
                                            Text("${messagesReceive[index]['sendable']['first_name']} ${messagesReceive[index]['sendable']['last_name']}",style: TextStyle(color:Colors.black,fontSize: 14.0,fontWeight: FontWeight.w500)),
                                            messagesReceive[index]['sendable']['role_front']!=null? Container(
                                              decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color:Colors.blue,
                                                        // border: Border.all(color: Colors.purple,width: 1.5)
                                                      ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(4.0),
                                                      child: Text('${messagesReceive[index]['sendable']['role_front']}',style: TextStyle(
                                                          fontSize: 9.5,
                                                          color: Colors.white
                                                      )),
                                                    ),):height(0),
                                            // Row(
                                            //   children: [
                                            //     Text("${messagesReceive[index]['sendable']['first_name']} ${messagesReceive[index]['sendable']['last_name']}",style: TextStyle(color:Colors.black,fontSize: 14.0,fontWeight: FontWeight.w500)),
                                            //     width(5),
                                            //     messagesReceive[index]['sendable']['role']!=null? Container(
                                            //       child: Padding(
                                            //         padding: const EdgeInsets.all(4.0),
                                            //         child: Text('${messagesReceive[index]['sendable']['role']}',style: TextStyle(
                                            //             fontSize: 9.5,
                                            //             color: Colors.white
                                            //         )),
                                            //       ),
                                            //       decoration: BoxDecoration(
                                            //         borderRadius: BorderRadius.circular(10),
                                            //         color:Colors.blue,
                                            //         // border: Border.all(color: Colors.purple,width: 1.5)
                                            //       ),
                                            //     ):height(0),
                                            //   ],
                                            // ),
                                            height(3),
                                            Text("${formattedDate}",style: TextStyle(color: Colors.grey[400],fontSize: 9.0,fontWeight: FontWeight.w500)),



                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: GestureDetector(
                                        onTap: (){
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context, builder: (context){
                                            return Container(
                                              color: Colors.white,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Form(
                                                  key: fromkey,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      height(50),
                                                      Align(
                                                        alignment: Alignment.topRight,
                                                        child: Text("عنوان الرسالة",style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:FontWeight.w500,
                                                        ),),
                                                      ),
                                                      height(15),
                                                      Directionality(
                                                        textDirection:ui.TextDirection.rtl,
                                                        child: DefaultTextfiled(
                                                            maxLines: 1,
                                                            label: "اكتب عنوان رسالة",
                                                            controller: Titrecontroller,
                                                            hintText:"اكتب عنوان رسالة",
                                                            keyboardType: TextInputType.text,
                                                            obscureText: false
                                                        ),
                                                      ),
                                                      height(20),
                                                      Align(
                                                        alignment: Alignment.topRight,
                                                        child: Text("رسالة",style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:FontWeight.w500,
                                                        ),),
                                                      ),
                                                      height(15),
                                                      Directionality(
                                                        textDirection:ui.TextDirection.rtl,
                                                        child: DefaultTextfiled(
                                                            maxLines: 5,
                                                            label:"اكتب رسالتك هنا",
                                                            controller: Messagecontroller,
                                                            hintText:"اكتب رسالتك هنا",
                                                            keyboardType: TextInputType.text,
                                                            obscureText: false
                                                        ),
                                                      ),
                                                      height(20),
                                                      StatefulBuilder(
                                                        builder: (context,SetState){
                                                          return GestureDetector(
                                                            onTap: ()async{
                                                              if (fromkey.currentState.validate()) {
                                                                fromkey.currentState.save();
                                                                var data = {
                                                                  "message": "${Messagecontroller.text}",
                                                                  "title":"${Titrecontroller.text}",
                                                                  "message_id":messagesReceive[index]['id'],
                                                                  "type":"${messagesReceive[index]['type']}"
                                                                };
                                                                SetState(() {
                                                                  isloading = false;
                                                                });
                                                                print(data);
                                                                final response = await http.post(
                                                                    Uri.parse('${url}/api/v1/user/professeur/messages'),
                                                                    body:jsonEncode(data),
                                                                    headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
                                                                ).then((value){
                                                                  if(value.statusCode==200){
                                                                    var data = json.decode(value.body);
                                                                    printFullText(data.toString());
                                                                    Fluttertoast.showToast(
                                                                        msg:"تم ارسال رسالة بنجاح",
                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                        gravity: ToastGravity.BOTTOM,
                                                                        webShowClose:false,
                                                                        backgroundColor: Colors.green,
                                                                        textColor: Colors.white,
                                                                        fontSize: 16.0
                                                                    );
                                                                    Messagecontroller.clear();
                                                                    Titrecontroller.clear();
                                                                    Navigator.pop(context);
                                                                    SetState(() {
                                                                      isloading = true;
                                                                    });
                                                                  }else{
                                                                    SetState(() {
                                                                      var data = json.decode(value.body);

                                                                      Messagecontroller.clear();
                                                                      Titrecontroller.clear();
                                                                      printFullText(data.toString());
                                                                      Fluttertoast.showToast(
                                                                          msg: 'error',
                                                                          toastLength: Toast.LENGTH_SHORT,
                                                                          gravity: ToastGravity.BOTTOM,
                                                                          webShowClose:false,
                                                                          backgroundColor: Colors.green,
                                                                          textColor: Colors.white,
                                                                          fontSize: 16.0
                                                                      );
                                                                      Navigator.pop(context);
                                                                      isloading = true;
                                                                    });
                                                                  }

                                                                }).onError((error,stackTrace){
                                                                  SetState(() {
                                                                    isloading = true;
                                                                    Navigator.pop(context);
                                                                    Messagecontroller.clear();
                                                                    Titrecontroller.clear();
                                                                    printFullText(error.toString());
                                                                    Fluttertoast.showToast(
                                                                        msg: 'error',
                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                        gravity: ToastGravity.BOTTOM,
                                                                        webShowClose:false,
                                                                        backgroundColor: Colors.green,
                                                                        textColor: Colors.white,
                                                                        fontSize: 16.0
                                                                    );
                                                                  });
                                                                  print(error);
                                                                });
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 60,
                                                              width: double.infinity,
                                                              decoration: BoxDecoration(
                                                                color:Colors.blue,
                                                                borderRadius:BorderRadius.circular(5),
                                                              ),
                                                              child:Center(child: isloading?Text("إرسال",style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 17
                                                              ),):CircularProgressIndicator(color: Colors.white,)),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                        child: Text("رد",style: TextStyle(color: Colors.lightBlue,
                                            fontWeight: FontWeight.bold,fontSize: 14),),
                                      ),
                                    )
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("${messagesReceive[index]['message']}",style: TextStyle(color:Colors.black)),
                                ),

                              ]),
                        ),
                      )
                  ),
                );
              },
              separatorBuilder:(context,index){
                return Divider();
              }, itemCount:messagesReceive.length)
        ],
      ),
    ):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
          child: Text('لا توجد اي الرسائل الواردة',style: TextStyle(color:Color(0xFF6b7280),fontSize: 16,fontWeight: FontWeight.w500,),textAlign: TextAlign.center,),
        ),
      ],
    ):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.blue)
      ],
    );
  }
}
