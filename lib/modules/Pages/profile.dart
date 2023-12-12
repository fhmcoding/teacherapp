import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teacherapp/shared/components/components.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';
import '../Login/login.dart';

bool isShowOld = true;
bool isShowNew = true;
class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  bool isloading = true;
  TextEditingController oldPasswordcontroller = TextEditingController();
  TextEditingController newPasswordcontroller = TextEditingController();
  String access_token = Cachehelper.getData(key: "token");
  int id = Cachehelper.getData(key: "id");
  String firstname = Cachehelper.getData(key: "first_name");
  String lastname = Cachehelper.getData(key: "last_name");
  String cin = Cachehelper.getData(key: "user_cin");
  String avatar = Cachehelper.getData(key: "avatar");

  Future UpdatePassword()async{
    var data = {"current_password":"${oldPasswordcontroller.text}","new_password":"${newPasswordcontroller.text}"};
    setState(() {
      isloading = false;
    });
    final response = await http.put(
        Uri.parse('${url}/api/v1/user/professeur/users/${id}/update-password'),
        body:jsonEncode(data),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);

        Fluttertoast.showToast(
            msg: "تم تعديل بنجاح",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            webShowClose:false,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );

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

  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();

  File _image;
  String img64;
  Uint8List bytes;
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        bytes =File(pickedFile.path).readAsBytesSync();
        img64 = base64Encode(bytes);
        UpdateAvatar(img64:img64);
      });
    }
  }
  bool isUpadateloading = true;

  Future UpdateAvatar({img64})async{
    var data = {"avatar":"${img64}"};
    setState(() {
      isUpadateloading = false;
    });
    final response = await http.put(
        Uri.parse('${url}/api/v1/user/professeur/users/${id}/update-avatar'),
        body:jsonEncode(data),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);
        setState(() {
          Cachehelper.sharedPreferences.setString("avatar",data['avatar']);
          isUpadateloading = true;
        });
      }else{
        setState(() {
          print(value.body);
          isUpadateloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation:0,
        centerTitle: true,
        title:Text('حسابي',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
      ),
      body:
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 20,left: 20,top: 20),
          child: Center(
            child: Form(
              key: fromkey,
              child: Column(
                children:[
                 Stack(
                   alignment: Alignment.bottomRight,
                   children: [

                     _image!=null?  CircleAvatar(
                       maxRadius: 75,
                       backgroundImage:FileImage(_image)
                     ):Container(
                       height: 150,
                       width: 150,
                       decoration: BoxDecoration(
                         color: Colors.grey[100],
                         shape: BoxShape.circle,
                       ),
                       child:
                       CachedNetworkImage(
                           height: 150,
                           width: 150,
                           imageUrl: '${avatar}',
                           placeholder: (context, url) =>
                              CircularProgressIndicator(),
                           errorWidget: (context, url, error) => Image.asset('assets/default.png'),
                           imageBuilder: (context, imageProvider){
                             return Container(
                               decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 image: DecorationImage(
                                   image: imageProvider,
                                   fit: BoxFit.cover,
                                 ),
                               ),
                             );
                           }
                       ),
                     ),

                     CircleAvatar(
                       maxRadius: 21.5,
                       backgroundColor: Colors.white,
                       child: CircleAvatar(
                         child:isUpadateloading?IconButton(
                             splashRadius: 25,
                             onPressed: (){
                               _pickImage(ImageSource.gallery);
                             }, icon:Icon(Icons.camera_alt_outlined,size: 23)):Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: CircularProgressIndicator(color: Colors.white),
                             ),
                       ),
                     )
                   ],
                 ),
                  height(20),
                  Text('${firstname} ${lastname}',style: TextStyle(
                    fontWeight: FontWeight.w500
                  )),
                  height(5),
                  Text('${cin}',style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Colors.grey[600]
                  )),
                  Padding(
                    padding: const EdgeInsets.only(right: 10,left: 10,top: 5),
                    child: GestureDetector(
                      onTap: (){
                        Cachehelper.removeData(key: "token").then((value){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,color: Colors.blue,size: 21),
                          width(8),
                          Text('تسجيل الخروج',style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                  ),
                  height(25),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text('كلمة سر قديمة',style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  height(15),
                  DefaultTextfiled(
                      maxLines: 1,
                      label: "كلمة سر قديمة",
                      controller: oldPasswordcontroller,
                      hintText: 'كلمة سر قديمة',
                      keyboardType: TextInputType.text,
                      onTap: (){
                        setState(() {
                          isShowOld =! isShowOld;
                        });
                      },
                      obscureText: isShowOld,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon:isShowOld? Icons.visibility_off_outlined:Icons.visibility
                  ),
                  height(20),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text('كلمة سر جديدة',style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  height(15),
                  DefaultTextfiled(
                      maxLines: 1,
                      label: "كلمة سر جديدة",
                      controller: newPasswordcontroller,
                      hintText: 'كلمة سر جديدة',
                      keyboardType: TextInputType.text,
                      onTap: (){
                        setState(() {
                          isShowNew =! isShowNew;
                        });
                      },
                      obscureText: isShowNew,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon:isShowNew? Icons.visibility_off_outlined:Icons.visibility
                  ),
                  height(25),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0,
                        right: 0
                    ),
                    child: GestureDetector(
                      onTap: (){
                        if (fromkey.currentState.validate()) {
                            fromkey.currentState.save();
                             UpdatePassword();
                        }
                      },
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius:BorderRadius.circular(5),
                        ),
                        child:Center(child:isloading? Text('تعديل',style: TextStyle(
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
        ),
      ),
    );
  }
}
