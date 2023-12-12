import 'package:flutter/material.dart';

import '../../Layout/HomeLayout/home.dart';
import '../../shared/remote/cachehelper.dart';
import '../Login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String token = Cachehelper.getData(key: "token");

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      if(token!= null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisAlignment:MainAxisAlignment.center,
                crossAxisAlignment:CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png')
                ],
              ),
            )
          ],
        )
    );
  }
}
