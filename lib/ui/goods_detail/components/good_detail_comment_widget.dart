import 'package:flutter/material.dart';
import 'package:flutter_app/component/global.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/ui/goods_detail/components/common_item_widget.dart';
import 'package:flutter_app/ui/goods_detail/components/gd_button_style.dart';
import 'package:flutter_app/ui/goods_detail/model/commondPageModel.dart';
import 'package:flutter_app/ui/router/router.dart';

typedef void OnPress();

///商品详情品论展示区
class GoodDetailCommentWidget extends StatelessWidget {
  final List<ResultItem>? comments;
  final num? commentCount;
  final String? goodCmtRate;
  final OnPress? onPress;
  final num? goodId;

  const GoodDetailCommentWidget(
      {Key? key,
      this.comments,
      this.commentCount = 0,
      this.goodCmtRate,
      this.goodId,
      this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildWidget(context);
  }

  _buildWidget(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            TextButton(
              style: gdButtonStyle,
              onPressed: () {
                if (commentCount != 0)
                  Routers.push(Routers.comment, context, {'id': goodId});
              },
              child: Container(
                height: 50,
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '用户评价($commentCount)',
                        style: t14black,
                      ),
                    ),
                    if (commentCount != 0)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${goodCmtRate ?? ''}',
                              style: num16Red,
                            ),
                            Text(
                              goodCmtRate == null || goodCmtRate!.isEmpty
                                  ? '查看全部'
                                  : '好评率',
                              style: t14black,
                            ),
                            arrowRightIcon
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              margin: EdgeInsets.only(left: 10),
              color: lineColor,
            ),
            if (comments!.length > 0)
              CommonItemWidget(
                item: comments![0],
              ),
          ],
        ));
  }
}
