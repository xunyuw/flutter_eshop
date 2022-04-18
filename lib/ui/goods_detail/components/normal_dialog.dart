import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ui/goods_detail/components/diaolog_title_widget.dart';

class NormalDialog {
  final Widget child;
  final String title;
  final double maxHeight;

  NormalDialog({
    required this.child,
    this.title = '',
    this.maxHeight = 400.0,
  });

  build(BuildContext context) async {
    return _showDialog(context);
  }

  _showDialog(BuildContext context) {
    //底部弹出框,背景圆角的话,要设置全透明,不然会有默认你的白色背景
    return showModalBottomSheet(
      //设置true,不会造成底部溢出
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(5.0),
            ),
          ),
          child: Column(
            children: [
              DialogTitleWidget(title: '$title'),
              Expanded(
                child: child,
              )
            ],
          ),
        );
      },
    );
  }
}
