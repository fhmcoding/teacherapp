import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({Key key}) : super(key: key);

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
 bool _isLoading = false;
 @override
  void initState() {
  
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Icon(Icons.balance_sharp,size: 100,),
            Text('القانون الداخلي'),
            SizedBox(height: 20,),
            Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.blue,
                  borderRadius: BorderRadius.circular(7)
                ),
                child: TextButton(onPressed: (){
                  launch('https://api.sofia-sahara.com/pdf.pdf');
                }, child:Text('فتح',style: TextStyle(
                  color: Colors.white
                ),)))
          ],
        ),
      )
    );
  }
}
