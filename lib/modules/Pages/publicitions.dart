import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:open_filex/open_filex.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:teacherapp/shared/components/components.dart';
import 'dart:io';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
class Publications extends StatefulWidget {
   Publications({Key key}) : super(key: key);

  @override
  State<Publications> createState() => _PublicationsState();
}

class _PublicationsState extends State<Publications> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  String access_token = Cachehelper.getData(key: "token");
  var result ='';
  bool isloading = true;

  TextEditingController titleAnnonceController = TextEditingController();
  TextEditingController descriptionAnnonceController = TextEditingController();
  String selectedOption = 'اختر النوع';
  String selectType = '';
  List<String> options = ['اختر النوع', 'Annonce', 'Activité','Devoir'];

  List<XFile>imageFileList=[];
  String img64;
  Uint8List bytes;
  final ImagePicker _picker = ImagePicker();

  List imageBytesList = [];

  List<String> base64Images = [];
  List<String> base64Files = [];
  List<String> base64Pdf = [];
  List<String> base64Word = [];

  List _selectedGroup = [];

  Future<void> selectImages() async {
    if (base64Images.isNotEmpty) {
      base64Images.clear();
    }
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      if (base64Images.isNotEmpty) {
        base64Images.clear();
        setState(() {});
      }

      for (final imageFile in selectedImages) {
        final Uint8List bytes = await imageFile.readAsBytes();
        final String base64Image = base64Encode(bytes); // Encode bytes as base64
        base64Images.add(base64Image);
      }
      setState(() {});
    }
  }

  List<String>images=[];

  List _selectedItems = [];

  List _groups = [];


  void _toggleItem(item) {
    setState(() {
      print(item);
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _toggleItembyGroup(item) {
    print('---------------->');
    print(item);
    print('---------------->');
    setState(() {
      if (_selectedGroup.contains(item['name'])){
        _selectedGroup.remove(item['name']);
      } else {
        _selectedGroup.add(item['name']);
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
                  title: Text('اختر المجموعة'),
                  content: SingleChildScrollView(
                    child:isgrouploading?Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _groups.map((item) {
                        return CheckboxListTile(
                          title: Text('  المجموعة ${item['name']}'),
                          value: _selectedItems.contains(item['id']),
                          onChanged: (bool value) {
                            stateState((){
                              _toggleItem(item['id']);
                              _toggleItembyGroup(item);
                            });
                          },
                        );
                      }).toList(),
                    ):Padding(
                      padding: const EdgeInsets.only(right: 90,left: 90),
                      child: Container(height: 50,width: 10,color: Colors.white,child: Center(child: CircularProgressIndicator()),),
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

  Future postPublication()async{
    print(_selectedItems);
    var data = {
      "title":"${titleAnnonceController.text}",
      "description":"${descriptionAnnonceController.text}",
      "type":selectType,
      "groups":_selectedItems,
      "base64_images":base64Images,
      "base64_files":base64Pdf,
      "base64_msword_files":base64Word,
      "links":_links
    };
    print(data);
    setState(() {
      isloading = false;
    });
    final response = await http.post(
      Uri.parse('${url}/api/v1/user/professeur/publications'),
      body:jsonEncode(data),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        Fluttertoast.showToast(
            msg: "تم نشر اعلان بنجاح",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            webShowClose:false,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        titleAnnonceController.clear();
        descriptionAnnonceController.clear();
        descriptionAnnonceController.clear();
        selectedOption = 'اختر النوع';
        _selectedItems.clear();
        _selectedGroup.clear();
        base64Images.clear();
        base64Pdf.clear();
        base64Word.clear();
        Links.clear();
        media.clear();
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

  List media = [];
  List groups = [];
  bool isgrouploading = true;

  Future getGroup() async {
    setState(() {
      isgrouploading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/api/v1/user/professeur/groups'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
      ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        Set<int> seenIds = Set<int>();
        for (var group in data['data']) {
          int id = group["id"];
          if (!seenIds.contains(id)) {
            groups.add(group);
            seenIds.add(id);
          }
        }
        groups.forEach((element){
          _groups.add({
            "name":element['name'],
            "id":element['id']
          });
        });
        print(groups);
        setState(() {
          isgrouploading = true;
        });
      }else{
        setState(() {
          print(value.body);
          isgrouploading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }


    List<TextEditingController> Links = [];
    List _links =[];



  @override
  void initState() {
    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    getGroup();
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
       appBar:AppBar(
         backgroundColor: Colors.white,
         elevation:0,
         centerTitle: true,
         title:Text('اعلانات',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
       ),
        body:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15,left: 10,top: 20),
            child: Form(
              key:fromkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('عنوان الاعلان',style: TextStyle(
                    fontSize: 16,
                    fontWeight:FontWeight.w500,
                  ),),
                  height(15),
                  DefaultTextfiled(
                    maxLines: 1,
                    label: "عنوان الاعلان",
                    controller: titleAnnonceController,
                    hintText: 'عنوان اعلان',
                    keyboardType: TextInputType.text,
                    obscureText: false
                  ),
                  height(10),
                  Text('وصف الاعلان',style: TextStyle(
                    fontSize: 16,
                    fontWeight:FontWeight.w500,
                  ),),
                  height(10),
                  DefaultTextfiled(
                    maxLines: 2,
                      label: "وصف الاعلان",
                      controller: descriptionAnnonceController,
                      hintText: 'وصف الاعلان',
                      keyboardType: TextInputType.text,
                      obscureText: false
                  ),
                  height(10),
                  Text('اختر النوع',style: TextStyle(
                    fontSize: 16,
                    fontWeight:FontWeight.w500,
                  ),),
                  height(10),
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
                            if(newValue=='Activité'){
                              selectedOption = newValue;
                              selectType = 'activity';
                            }
                            if(newValue=='Annonce'){
                            selectedOption = newValue;
                            selectType = 'announcement';
                            }
                            if(newValue=='Devoir'){
                              selectedOption = newValue;
                              selectType = 'devoir';
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
                                  Icon(Icons.ads_click,color:Color(0xff9BABB8)),
                                  SizedBox(width: 10,),
                                  Text(value,textDirection: TextDirection.ltr),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  height(10),
                  Text('اختر المجموعة',style: TextStyle(
                  fontSize: 16,
                  fontWeight:FontWeight.w500,
                  ),),
                  height(10),
                  GestureDetector(
                    onTap: (){
                      isgrouploading? _showAlertDialog(context):null;
                    },
                    child: Container(
                      height: 60,
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
                              child:_selectedGroup.length>0?Text('${_selectedGroup.map((e) => e).join(' , ')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                maxLines:2,
                              ):Text('اختر المجموعة'),
                            ),
                          ),
                          IconButton(
                              splashRadius:10,
                              onPressed: (){
                                _showAlertDialog(context);
                              }, icon:Icon(Icons.arrow_drop_down))
                        ],
                      ),
                    ),
                  ),

                  height(10),
                  Text('رفع الملف',style: TextStyle(
                    fontSize: 16,
                    fontWeight:FontWeight.w500,
                  ),),
                  height(10),
                  GestureDetector(
                    onTap: (){
                     showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context, builder: (context)=>StatefulBuilder(builder: (context,SetState){
                            return Container(
                              height: 355,
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                margin: EdgeInsets.all(18),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 150,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount:media.length,
                                          itemBuilder: (context,index){
                                            return attachementWidget(media[index],(index){
                                              SetState(() {
                                                media.removeAt(index);
                                              });
                                            },
                                            index
                                            );
                                          }),
                                    ),
                                    height(20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        iconcreation(icon:Icons.image,color: Colors.red,title:'Gallery',onTap: ()async{
                                          final List<XFile> selectedImages = await _picker.pickMultiImage();
                                          if(selectedImages!=null){
                                            for(var i = 0;i<selectedImages.length;i++){
                                              File file = File(selectedImages[i].path);
                                              SetState(() {
                                                media.add({
                                                  "type":"image",
                                                  "file":file
                                                });
                                              });
                                              final Uint8List bytes = await file.readAsBytes();
                                              final String base64Image = base64Encode(bytes); // Encode bytes as base64
                                              base64Images.add(base64Image);
                                              print(base64Images);
                                            }
                                          }
                                        }),
                                        SizedBox(width: 40,),
                                        iconcreation(icon:Icons.file_present_rounded,color: Colors.blue,title:'Document',onTap: ()async{
                                          final result = await FilePicker.platform.pickFiles();
                                          if(result!=null){
                                            PlatformFile document = result.files.first;
                                            String filePath = document.path;
                                            File file = File(filePath);
                                            List<int> fileBytes = file.readAsBytesSync();
                                            String base64file = base64Encode(fileBytes);
                                            String extension = lookupMimeType(result.files.single.path);

                                            List<String> myArray = extension.split('/');
                                            if(myArray[1].contains('word')){
                                              base64Word.add(base64file);
                                            }
                                            if(myArray[1].contains('pdf')){
                                              base64Pdf.add(base64file);
                                            }
                                            SetState(() {
                                              media.add({
                                                "type":"docs",
                                                "file":File(result.files.single.path),
                                                "extension":myArray[1].contains('pdf') ? "pdf" : myArray[1].contains('presentation')? "power-point":myArray[1].contains('sheet')?
                                                "excel":myArray[1].contains('document')? "word":myArray[0]=='image'?"image":myArray[0]=='video'?"video":""
                                              });
                                            });
                                            }


                                        }),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                        height: 40,
                                        width: 100,
                                        color: Colors.red,
                                        child: TextButton(onPressed: (){
                                          Navigator.pop(context);
                                        }, child: Text('Upload',style: TextStyle(
                                          color: Colors.white
                                        ),)))

                                  ],
                                ),
                              ),
                            );
                      }));
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 1,
                            color: Color(0xff9BABB8),
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15,right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.attachment_rounded,size: 40,color: Color(0xff9BABB8),),
                                width(5),
                                Text('اختر الملفات التي تريد رفعها',style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:FontWeight.w500,
                                    color: Colors.black
                                ),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  height(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('أضف روابط',style: TextStyle(
                        fontSize: 16,
                        fontWeight:FontWeight.w500,
                      ),),

                      GestureDetector(
                        onTap: (){
                          setState(() {
                           Links.add(TextEditingController());
                          });
                        },
                        child: Container(
                          height:30,
                          width:30,
                          decoration:BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                width: 1,
                                color: Color(0xff9BABB8),
                              )
                          ),

                          child:Icon(Icons.add),
                        ),
                      )
                    ],
                  ),
                  height(10),

                  ListView.builder(
                      shrinkWrap:true,
                      itemCount:Links.length,
                      itemBuilder:(context,index){
                        print("${Links[index].text==''}");
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:Links[index].text!=''?Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                         Expanded(child: Text('${Links[index].text}',maxLines: 1,overflow: TextOverflow.ellipsis,)),
                          width(10),
                          GestureDetector(
                              onTap:(){
                                setState(() {
                                  Links.removeAt(index);
                                });
                              },
                              child: Icon(Icons.clear,color: Colors.red)),
                        ],
                      ):Row(
                        children:[
                          Expanded(
                            child:TextField(
                              decoration:InputDecoration(
                                hintText:'أدخل الرابط هنا...',
                              ),
                              controller:Links[index],
                            ),
                          ),
                          width(10),
                          GestureDetector(
                           onTap:(){
                             setState((){
                               _links.add(Links[index].text);
                             });
                            },
                           child:Icon(Icons.check,color: Colors.green)),
                          width(15),
                          GestureDetector(
                              onTap:(){
                                setState(() {
                                  Links.removeAt(index);
                                });
                              },
                              child: Icon(Icons.clear,color: Colors.red)),
                        ],
                      ),
                    );
                  }),
                  height(20),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 0,
                      right: 0
                    ),
                    child: GestureDetector(
                      onTap: (){

                       if (fromkey.currentState.validate()) {
                           fromkey.currentState.save();
                           if(selectedOption == 'اختر النوع'||_selectedItems.isEmpty){
                             Fluttertoast.showToast(
                                 msg: "اختر النوع او اختر المجموعة",
                                 toastLength: Toast.LENGTH_SHORT,
                                 gravity: ToastGravity.TOP,
                                 webShowClose:false,
                                 backgroundColor: Colors.red,
                                 textColor: Colors.white,
                                 fontSize: 16.0,
                             );
                           }
                           else{
                             postPublication();
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
                        child:Center(child:isloading?Text('اضافة الاعلان',style: TextStyle(
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



  Widget iconcreation({IconData icon,Color color,String title,Function onTap}){
    return GestureDetector(
      onTap:onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:color,
            child: Icon(icon,size: 29,color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(title,style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w300
          ),)

        ],
      ),
    );
  }

  Widget attachementWidget(Map<String,dynamic>attachement,Function removeAttachement,index){
     return Stack(
       children: [
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: GestureDetector(
             onTap: (){
               OpenFilex.open(attachement['file'].path);
               print(attachement['file'].path);
             },
             child: Container(
               height: 120,
               width: 120,
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(5)
               ),
               child:attachement['type']=="image"? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                   child: Image.file(attachement['file'],fit: BoxFit.cover)):attachement['type']=="docs"?Align(
                    child:attachement['extension']=="word"?ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network('https://1000logos.net/wp-content/uploads/2020/08/Microsoft-Word-Logo-2013.png',fit:BoxFit.cover))
                     :attachement['extension']=="pdf"?ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network('https://img.freepik.com/vecteurs-premium/fichier-au-format-pdf-modele-pour-votre-conception_97886-11001.jpg',fit:BoxFit.cover)):attachement['extension']=="image"?Image.file(attachement['file']):attachement['extension']=="video"?Stack(
                         alignment: Alignment.center,
                         children: [
                          CircleAvatar(
                           backgroundColor: Colors.deepPurple,
                           child: IconButton(onPressed: (){}, icon:Icon(Icons.play_arrow_rounded,color: Colors.white,)),
                          ),
                       ],
                     ):Container(),
               ):Container(),
             ),
           ),
         ),
        GestureDetector(
          onTap: (){
           removeAttachement(index);
          },
          child: Padding(padding: EdgeInsets.all(12),child:CircleAvatar(
            backgroundColor: Colors.red,
            child:Icon(Icons.delete,size: 17,color: Colors.white),
            maxRadius: 15,
          )),
        )
       ],
     );
  }
}

