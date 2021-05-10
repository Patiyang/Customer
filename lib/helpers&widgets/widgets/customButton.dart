import 'package:flutter/material.dart';
import 'package:my_cab/constance/global.dart';

import 'customText.dart';

class CustomFlatButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Color iconColor;
  final VoidCallback callback;
  // final ShapeBorder shape;
  final double height;
  final double width;
  final double radius;
  final double iconSize;
  final icon;
  final double fontSize;

  const CustomFlatButton(
      {Key key,
      this.text,
      this.color,
      this.callback,
      this.textColor,
      this.height,
      this.width,
      this.radius,
      this.icon,
      this.fontSize,
      this.iconColor,
      this.iconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: MaterialButton(
        elevation: 0,
        height: height ?? 45,
        minWidth: width ?? 300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius))),
        onPressed: callback,
        color: color ?? blue,
        child: Container(
          // width: width ?? 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon == null
                  ? SizedBox.shrink()
                  : Icon(
                      icon,
                      size: iconSize ?? 17,
                    ),
              SizedBox(
                width: 5,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: CustomText(color: textColor,
                  maxLines: 1,
                  text: text ?? 'Okay',
                  size: fontSize,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
