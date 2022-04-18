import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';

class MTextFiled extends TextField {
  MTextFiled(
      {final TextEditingController? controller,
      final int maxLines = 1,
      int? maxLength,
      String counterText = '',
      TextInputType? keyboardType,
      String? hintText})
      : super(
          style: t16black,
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          decoration: InputDecoration(
              fillColor: Colors.white,
              hintStyle: t14lightGrey,
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: lineColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(2)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: redColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(2)),
              hintText: hintText,
              counterText: counterText),
        );
}
