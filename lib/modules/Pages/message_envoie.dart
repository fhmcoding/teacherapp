import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teacherapp/shared/components/components.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';

class Message_envoie extends StatefulWidget {
   Message_envoie({Key key}) : super(key: key);

  @override
  State<Message_envoie> createState() => _Message_envoieState();
}

class _Message_envoieState extends State<Message_envoie> {
  String access_token = Cachehelper.getData(key: "token");
  TextEditingController Titrecontroller = TextEditingController();

  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();

  List _groups = [];
  bool isloading = true;
  bool isloadingdata = true;

  Future getUsers()async {
    print(selectType);
      setState(() {
        isloadingdata = false;
      });
    final response = await http.get(
        Uri.parse('${url}/api/v1/user/professeur/users'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);
        _groups = data['data'];
        setState(() {
          isloadingdata = true;
        });
      }else{
        var data = json.decode(value.body);
        print(data);
        setState(() {
          isloadingdata = true;

        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }

  Future getGuardians()async {
    print(selectType);
    setState(() {
      isloadingdata = false;
    });
    final response = await http.get(
        Uri.parse('${url}/api/v1/user/professeur/guardians'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);
        _groups = data['data'];
        setState(() {
          isloadingdata = true;
        });
      }else{
        setState(() {
          var data = json.decode(value.body);
          isloadingdata = true;
          print(data);
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }

  TextEditingController Messagecontroller = TextEditingController();

  String selectedOption = 'اختر نوع الرسالة';
  String selectType = '';
  String selectedType = '';
  List<String> options = ['اختر نوع الرسالة', 'Interne', 'Externe',];


  String selecteGroup = 'الى';

  List _selectedItems = [];

  List _selectedNames = [];



  Future postMessage() async {
    var data = {
      "recipients":_selectedItems,
      "title":"${Titrecontroller.text}",
      "type":selectType,
      "message":"${Messagecontroller.text}"
    };
    setState((){
      isloading = false;
      print(data);
    });
    final response = await http.post(
        Uri.parse('${url}/api/v1/user/professeur/messages'),
        body:jsonEncode(data),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);
        Fluttertoast.showToast(
            msg: "تم ارسال رسالة بنجاح",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            webShowClose:false,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        selectedOption = 'اختر نوع الرسالة';
        Messagecontroller.clear();
        setState(() {
          isloading = true;
        });
      }else{
        setState(() {
          print(value.body);
          isloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }

  void _toggleItem(item) {
    print('---------------->');
    print(item);
    print('---------------->');
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }
  void _toggleItembyName(item) {
    print('---------------->');
    print(item);
    print('---------------->');
    setState(() {
      if (_selectedNames.contains(item['first_name'])){
        _selectedNames.remove(item['first_name']);
      } else {
        _selectedNames.add(item['first_name']);
      }
    });
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, stateState){
              return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text('الى'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _groups.map((item) {
                        return item['role']!='autre'?CheckboxListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(item['full_name']),
                              item['role_front']!=null?Text('${item['role_front']}',style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12
                              ),):height(0),
                              item['students']!=null? Text('${item['students'].map((e) => e['full_name']).join(' , ')}',style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12
                              ),):height(0)
                            ],
                          ),
                          value: _selectedItems.contains(item['id']),
                          onChanged: (bool value) {
                            stateState(() {
                             print(item['first_name']);
                             _toggleItembyName(item);
                              _toggleItem(item['id']);
                            });
                          },
                        ):height(0);
                      }).toList(),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('تاكيد'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 15,left: 10,top: 20),
        child: Form(
          key: fromkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height(10),
              Text('نوع الرسالة',style: TextStyle(
                fontSize: 16,
                fontWeight:FontWeight.w500,
              ),),
              height(15),
              Container(
                height: 60,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16,),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color:Color(0xff9BABB8),),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedOption,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.grey[600],),
                    onChanged: (String newValue) {
                      setState(() {
                        if(newValue=='Interne'){
                          selectedOption = newValue;
                          selectType = 'internal';
                          getUsers();
                        }
                        if(newValue=='Externe'){
                          selectedOption = newValue;
                          selectType = 'external';
                          getGuardians();
                        }
                      });

                    },
                    items:options.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                            children: [
                              Text(value,textDirection: TextDirection.ltr),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              height(20),
              selectedOption=='اختر نوع الرسالة'?height(0):height(5),
              selectedOption=='اختر نوع الرسالة'?height(0):Text('الى',style: TextStyle(
                fontSize: 16,
                fontWeight:FontWeight.w500,
              ),),
              selectedOption=='اختر نوع الرسالة'?height(0):height(5),
              selectedOption=='اختر نوع الرسالة'?height(0):GestureDetector(
                onTap: (){
                  isloadingdata? _showAlertDialog(context):null;
                },
                child: Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 1,
                        color: Color(0xff9BABB8),
                      )
                  ),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                          Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:_selectedNames.length>0?Text('${_selectedNames.map((e) => e).join(' , ')}',
                            style: TextStyle(
                              fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                            ),

                            maxLines:2,
                          ):Text('الى'),
                        ),
                      ),
                          isloadingdata?IconButton(
                          splashRadius:10,
                          onPressed: (){
                            isloadingdata?_showAlertDialog(context):null;
                          }, icon:Icon(Icons.arrow_drop_down)):Padding(
                            padding: const EdgeInsets.only(left:10),
                            child: CircularProgressIndicator(),
                          )
                    ],
                  ),
                ),
              ),
              selectedOption=='اختر نوع الرسالة'?height(0):height(5),
              selectedOption=='اختر نوع الرسالة'?height(0):height(5),
              Text('عنوان الرسالة',style: TextStyle(
                fontSize: 16,
                fontWeight:FontWeight.w500,
              ),),
              height(5),
              DefaultTextfiled(
                  maxLines: 1,
                  label:"اكتب عنوان الرسالة",
                  controller:Titrecontroller,
                  hintText:"اكتب عنوان الرسالة",
                  keyboardType:TextInputType.text,
                  obscureText: false
              ),
              height(15),
              Text('رسالة',style: TextStyle(
                fontSize: 16,
                fontWeight:FontWeight.w500,
              ),),
              height(5),
              DefaultTextfiled(
                  maxLines: 5,
                  label: "اكتب رسالتك هنا",
                  controller: Messagecontroller,
                  hintText: 'اكتب رسالتك هنا',
                  keyboardType: TextInputType.text,
                  obscureText: false
              ),
              height(25),
              Padding(
                padding: const EdgeInsets.only(
                    left: 0,
                    right: 0
                ),
                child: GestureDetector(
                  onTap:(){
                    if (fromkey.currentState.validate()) {
                       fromkey.currentState.save();
                       if(selectedOption == 'اختر نوع الرسالة'||_selectedItems.isEmpty){
                         Fluttertoast.showToast(
                           msg: "اختر نوع الرسالة او اختر لمن تريد ارساله",
                           toastLength: Toast.LENGTH_SHORT,
                           gravity: ToastGravity.TOP,
                           webShowClose:false,
                           backgroundColor: Colors.red,
                           textColor: Colors.white,
                           fontSize: 16.0,
                         );
                       }else{
                         postMessage();
                       }
                    }
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius:BorderRadius.circular(5),
                    ),
                    child:Center(child:isloading?Text('إرسال',style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17
                    ),):CircularProgressIndicator(color: Colors.white,)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
