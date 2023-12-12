
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../Layout/HomeLayout/home.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
bool isShow = true;
class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login>{

  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  var PhoneController = TextEditingController();
  var PasswordController = TextEditingController();
  var fbm = FirebaseMessaging.instance;

  String fcmtoken='';

  bool isloading = true;
   List groups = [];



  Future login({payload})async{
    isloading = false;
    final response = await http.post(
      Uri.parse('${url}/api/v1/auth/user/professeur'),
      body:jsonEncode(payload),
      headers:{'Content-Type':'application/json','Accept':'application/json',},
    ).then((value){
        if(value.statusCode==200){
          var data = json.decode(value.body);
          print(data);
          Cachehelper.sharedPreferences.setInt("id",data['user']['id']);
          if(data['user']['avatar']!=null){
            Cachehelper.sharedPreferences.setString("avatar",data['user']['avatar']);
          }
          if(data['user']['first_name'] != null){
            Cachehelper.sharedPreferences.setString("first_name",data['user']['first_name']);
          }
          if(data['user']['last_name']!= null){
            Cachehelper.sharedPreferences.setString("last_name",data['user']['last_name']);
          }
          if(data['user']['cin']!=null){
            Cachehelper.sharedPreferences.setString("user_cin",data['user']['cin']);
          }

          Cachehelper.sharedPreferences.setString("token",data['token']).then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
          });
        }else{
          var data = json.decode(value.body);
          setState(() {
            print(value.body);
            Fluttertoast.showToast(
                msg: "${data['message']}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
            isloading = true;
          });
        }

    }).onError((error, stackTrace){
      print(error);
    });
   return response;
  }

  @override
  Widget build(BuildContext context){
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Form(
          key: fromkey,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('تسجيل الدخول',style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(height: 20,),
                    DefaultTextfiled(
                      maxLines: 1,
                        controller: PhoneController,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        hintText: 'البريد الإلكتروني أو رقم الهاتف',
                        label:'البريد الإلكتروني أو رقم الهاتف',
                        prefixIcon: Icons.person
                    ),
                    SizedBox(height: 20,),
                    DefaultTextfiled(
                      maxLines: 1,
                        controller: PasswordController,
                        onTap: (){
                          setState(() {
                            isShow =! isShow;
                          });
                        },
                        obscureText: isShow,
                        hintText: 'كلمة المرور',
                        label:'كلمة المرور',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon:isShow? Icons.visibility_off_outlined:Icons.visibility
                    ),
                    //  SizedBox(height: 20,),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap:()async{
                        if (fromkey.currentState.validate()) {
                        fromkey.currentState.save();
                        setState(() {
                          isloading = false;
                        });
                        try {
                          final authcredential = await FirebaseAuth.instance.signInAnonymously();
                          if (authcredential.user != null) {
                            fbm.getToken().then((token) {
                              print(token);
                              fcmtoken = token;
                              printFullText(fcmtoken.toString());
                              login(payload: {
                                "email": "${PhoneController.text}",
                                "password": "${PasswordController.text}",
                                "firebase_token":fcmtoken
                              });
                            });
                          }
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            isloading = true;
                          });
                          print("error is ${e.message}");
                        }
                      }

                      },
                      child:
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color:Colors.blue
                        ),
                        child: Center(
                          child:isloading?Text('تسجيل الدخول',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ):CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        height: 55,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(height: 5,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
