import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void printFullText(String text) {
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
Widget DefaultTextfiled({bool obscureText,String hintText,String label,IconData prefixIcon,IconData suffixIcon,TextEditingController controller ,Function onTap,TextInputType keyboardType,int maxLines}){
  return TextFormField(
    maxLines: maxLines,
    keyboardType:keyboardType,
    obscureText: obscureText,
    controller:controller,
    style: TextStyle(color: Colors.black),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return '${hintText} لا يجب أن تكون فارغة ';
      }
      return null;
    },
    decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xff9BABB8),
            )),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xff9BABB8),
            )),
        hintText: hintText,
        label: Text(label),
        prefixIcon:prefixIcon!=null? Icon(prefixIcon):null,
        suffixIcon: suffixIcon!=null? GestureDetector(
            onTap:onTap,
            child: Icon(suffixIcon)):null,
        hintStyle: TextStyle(
          color: Color(0xFF7B919D),
        )),
  );
}

Widget height(
    double height,
    ) {
  return SizedBox(
    height: height,
  );
}

Widget width(
    double width,
    ) {
  return SizedBox(
    width: width,
  );
}
Widget buildNodata(context){
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset('assets/nondata.jpg'),
      Text('ا توجد بيانات للعرض',style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500
      ),)
    ],
  );
}