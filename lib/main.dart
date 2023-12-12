import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teacherapp/shared/remote/cachehelper.dart';
import 'Layout/HomeLayout/home.dart';
import 'modules/Login/login.dart';
import 'modules/Pages/splash_screen.dart';
Future<void> backgroundMessageHandler(RemoteMessage message){
  Fluttertoast.showToast(
      msg: "New Notification",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webShowClose:false,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Cachehelper.init();
  await Firebase.initializeApp();

  String token = Cachehelper.getData(key: "token");
  Widget widget;
  if(token!= null) widget = HomeScreen();
  else widget = Login();


  runApp(MyApp(startWidget:widget,));
}

class MyApp extends StatefulWidget {
  final Widget startWidget;
  const MyApp({Key key,this.startWidget}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
    FirebaseMessaging.onMessage.listen((message){
      if (message.notification!=null){
        Fluttertoast.showToast(
            msg: "New Notification",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            webShowClose:false,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    },);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Fluttertoast.showToast(
          msg: "New Notification",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          webShowClose:false,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enseignants | Ecole Sofai Sahara',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:SplashScreen(),
    );
  }
}

