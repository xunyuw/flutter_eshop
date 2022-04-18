import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';

///底部边框
BoxDecoration bottomBorder = BoxDecoration(
    border: Border(bottom: BorderSide(color: lineColor, width: 0.5)));

BoxDecoration topBorder = BoxDecoration(
  border: Border(top: BorderSide(color: backGrey, width: 0.5)),
  color: Colors.white,
);

///右指向箭头
Widget arrowRightIcon = Image.asset(
  'assets/images/arrow_right.png',
  width: 12,
  height: 12,
);

///右指向箭头
Widget arrowRightRed10Icon = Image.asset(
  'assets/images/arrow_right.png',
  width: 12,
  height: 12,
  color: textRed,
);
