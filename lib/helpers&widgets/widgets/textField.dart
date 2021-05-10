import 'package:flutter/material.dart';
import 'package:my_cab/constance/global.dart';

class LoginTextField extends StatelessWidget {
  final String hint;
  final iconOne;
  final iconTwo;
  final Color containerColor;
  final Color hintColor;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType textInputType;
  final TextAlign align;
  final double radius;
  final InputBorder inputBorder;
  final validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback callback;

  const LoginTextField(
      {Key key,
      this.hint,
      this.iconOne,
      this.iconTwo,
      this.containerColor,
      this.hintColor,
      this.controller,
      this.obscure,
      this.textInputType,
      this.align,
      this.radius,
      this.inputBorder,
      this.validator,
      this.maxLines,
      this.readOnly,
      this.callback})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3),
        child: TextFormField(
          onTap: callback,
          readOnly: readOnly ?? false,
          textAlign: align ?? TextAlign.start,
          keyboardType: textInputType,
          obscureText: obscure ?? false,
          validator: validator,
          controller: controller,
          maxLines: maxLines ?? 1,
          style: TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(radius ?? 15)), borderSide: BorderSide(color: grey[100])),
              suffixIcon: iconTwo,
              prefixIcon: iconOne,
              labelText: hint,
              hintStyle: TextStyle(color: hintColor ?? Colors.black),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 19)),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hint;
  final iconOne;
  final iconTwo;
  final Color containerColor;
  final Color hintColor;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType textInputType;
  final TextAlign align;
  final double radius;
  final InputBorder inputBorder;
  final validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback callback;

  const CustomTextField(
      {Key key,
      this.hint,
      this.iconOne,
      this.iconTwo,
      this.containerColor,
      this.hintColor,
      this.controller,
      this.obscure,
      this.textInputType,
      this.align,
      this.radius,
      this.inputBorder,
      this.validator,
      this.maxLines,
      this.readOnly,
      this.callback})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.all(Radius.circular(3))),
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: TextFormField(
          onTap: callback,
          readOnly: readOnly ?? false,
          textAlign: align ?? TextAlign.start,
          keyboardType: textInputType,
          obscureText: obscure ?? false,
          validator: validator,
          controller: controller,
          maxLines: maxLines ?? 1,
          style: TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: iconTwo,
            prefixIcon: iconOne,
            
            // labelText: hint,
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor ?? grey[600],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          ),
        ),
      ),
    );
  }
}

class CourierTextField extends StatelessWidget {
  final String hint;
  final iconOne;
  final iconTwo;
  final icon;
  final Color containerColor;
  final Color hintColor;
  final TextEditingController controller;
  final bool obscure;
  final bool readOnly;
  final TextInputType textInputType;
  final TextAlign align;
  final double radius;
  final InputBorder inputBorder;
  final validator;
  final onTap;

  const CourierTextField(
      {Key key,
      this.hint,
      this.iconOne,
      this.iconTwo,
      this.containerColor,
      this.hintColor,
      this.controller,
      this.obscure,
      this.textInputType,
      this.align,
      this.radius,
      this.inputBorder,
      this.validator,
      this.icon,
      this.readOnly,
      this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3),
        child: TextFormField(
          onTap: onTap,
          readOnly: readOnly ?? false,
          textAlign: align ?? TextAlign.start,
          keyboardType: textInputType,
          obscureText: obscure ?? false,
          validator: validator,
          controller: controller,
          style: TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          decoration: InputDecoration(
              border: UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(radius ?? 15))),
              icon: icon,
              suffixIcon: iconTwo,
              prefixIcon: iconOne,
              labelText: hint,
              alignLabelWithHint: true,
              labelStyle: TextStyle(color: hintColor ?? Colors.grey[500]),
              hintStyle: TextStyle(color: hintColor ?? Colors.grey[200]),
              contentPadding: EdgeInsets.all(6)),
        ),
      ),
    );
  }
}

class CustomRegisterTextField extends StatelessWidget {
  final String text;
  final bool password;
  final validator;
  final TextEditingController controller;
  final TextInputType textInputType;
  final Color fillColor;
  final bool readOnly;
  CustomRegisterTextField({this.text, this.password, this.validator, this.controller, this.textInputType, this.fillColor, this.readOnly});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: height * 0.06,
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: TextFormField(
          keyboardType: textInputType,
          readOnly: readOnly ?? false,
          controller: controller,
          validator: validator,
          obscureText: password ?? false,
          autofocus: true,
          decoration: InputDecoration(
            filled: false,
            fillColor: fillColor ?? Color(0xffF6F6F6),
            labelText: text,
            contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
          ),
        ),
      ),
    );
  }
}
