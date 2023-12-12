import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../shared/components/components.dart';
import '../../shared/remote/cachehelper.dart';
class Absences extends StatefulWidget {
  const Absences({Key key}) : super(key: key);
  @override
  State<Absences> createState() => _AbsencesState();
}

class _AbsencesState extends State<Absences> {
  bool isAbsenceloading = true;
  bool isloading = true;
  List absences = [];
  String access_token = Cachehelper.getData(key: "token");

  Future getAbsences() async {
    setState(() {
      isAbsenceloading = false;
    });
    final response = await http.get(
        Uri.parse('https://api.sofia-sahara.com/api/v1/user/professeur/attendance_records'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        absences = data['data'];
        print('-----------------------------------');

        print('-----------------------------------');
        setState(() {
          isAbsenceloading = true;
        });
      }else{
        setState(() {
          print(value.body);
          isAbsenceloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }
@override
  void initState() {
  getAbsences();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var WithoutJustification = absences.where((element) => element['justification']==null).toList();
    var WithJustification = absences.where((element) => element['justification']!=null).toList();
    return isloading?Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation:0,
        centerTitle: true,
        title:Text('الغياب',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            isAbsenceloading?absences.length>0?Padding(
              padding: const EdgeInsets.only(right: 25,left: 25,top: 5,bottom: 10),
              child:Column(
                children: [
                  Row(
                    children: [
                      Text('الغياب بدون مبرر : ',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),),

                      Text('${WithoutJustification.length}',style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13
                      ),),
                    ],
                  ),
                  Row(
                    children: [
                      Text('الغياب مبرر : ',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),),

                      Text('${WithJustification.length}',style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13
                      ),)
                    ],
                  ),
                  Row(
                    children: [
                      Text('المجموع الغياب :',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),),
                      width(0),
                      Text('${absences.where((element) =>element['type']=='absence').toList().length}',style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13
                      ),)
                    ],
                  ),
                ],
              ),
            ):height(0):height(0),
            isAbsenceloading?absences.length>0?  Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey[100],
            ):height(0):height(0),
            isAbsenceloading?absences.length>0?ListView.builder(
                itemCount:absences.length,
                physics: BouncingScrollPhysics(),
                shrinkWrap:true,
                itemBuilder:(context,index){
                  String inputDate = "${absences[index]['created_at']}";
                  // DateTime dateTime = DateTime.parse(inputDate);
                  // String formattedDate = DateFormat('HH:mm / d MMM').format(dateTime);
                  return absences[index]['type']=='absence'?
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color:Colors.grey[300],width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200],
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:10,right: 20,left: 20,bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text('الحصة :',style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13
                                    ),),
                                    width(4),
                                   Text('${absences[index]['session']}')
                                  ],
                                ),
                                Container(
                                  width:60,
                                  child:Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Center(
                                      child:Text('${absences[index]['type']=='delay'?"delay":"غياب"}',style: TextStyle(
                                          fontSize: 9.5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ))
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:Colors.purple,
                                    // border: Border.all(color: Colors.purple,width: 1.5)
                                  ),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                            Row(
                              children: [
                                Text('اليوم : ',style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13
                                ),),
                                width(4),

                                Text('${absences[index]['created_at']}',style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13
                                ),),
                              ],
                            ),
                            Row(
                              children: [
                                Text('مبرر الغياب : ',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),),
                                width(4),
                                Text(absences[index]['justification']!=null?'':'بدون مبرر',style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13
                                ),),
                              ],
                            ),


                          ],
                        ),
                      ),
                    ),
                  ):
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color:Colors.grey[300],width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200],
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:10,right: 20,left: 20,bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text('الحصة : ',style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13
                                    ),),
                                    width(4),
                                    Text('${absences[index]['session']}',style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13
                                    ),),
                                  ],
                                ),
                                Container(
                                  width:60,
                                  child:Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Center(
                                      child:Text('${absences[index]['type']=='delay'?"تأخير":"غياب"}',style: TextStyle(
                                          fontSize: 9.5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      )),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:Colors.purple,
                                    // border: Border.all(color: Colors.purple,width: 1.5)
                                  ),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                            Row(
                              children: [
                                Text('اليوم : ',style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13
                                ),),
                                width(4),
                                Text('${absences[index]['created_at']}',style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13
                                ),),
                              ],
                            ),
                            Row(
                              children: [
                                Text('مبرر التاخير: ',style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13
                                ),),
                                width(4),
                                Text(absences[index]['justification']!=null?'':"بدون مبرر",style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13
                                ),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }):Padding(
              padding: const EdgeInsets.only(right: 20,left: 20,top: 20),
              child: buildNodata(context),
            ):Center(child: Column(
              children: [
                height(100),
                CircularProgressIndicator(color: Colors.purple),
              ],
            )),
          ],
        ),
      ),
    ): Center(
      child:CircularProgressIndicator(color: Colors.purple),
    );
  }
}
