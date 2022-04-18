import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/ui/home/model/noticeListModel.dart';
import 'package:flutter_app/ui/mine/order/order_list_item_page.dart';
import 'package:flutter_app/ui/router/router.dart';
import 'package:flutter_app/utils/local_storage.dart';
import 'package:flutter_app/component/tab_app_bar.dart';

class OrderListPage extends StatefulWidget {
  final Map? params;

  const OrderListPage({Key? key, this.params}) : super(key: key);

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with TickerProviderStateMixin {
  late TabController _mController;

  NoticeListModel? _noticeListModel;

  var _tabItem = [
    {
      "name": "全部",
      "status": 0,
    },
    {
      "name": "待付款",
      "status": 1,
    },
    {
      "name": "待发货",
      "status": 3,
    },
    {
      "name": "已发货",
      "status": 4,
    },
    {
      "name": "待评价",
      "status": 5,
    }
  ];

  int? _activeIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.params!['tab'] != null) {
      setState(() {
        _activeIndex = widget.params!['tab'];
      });
    }
    _mController = TabController(
        length: _tabItem.length, vsync: this, initialIndex: _activeIndex!);
    super.initState();
    _getNotice();
  }

  @override
  Widget build(BuildContext context) {
    var title = _tabItem.map<String?>((e) => e["name"] as String?).toList();
    return Scaffold(
      backgroundColor: backColor,
      appBar: TabAppBar(
        scrollable: false,
        controller: _mController,
        tabs: title,
        title: '订单',
      ).build(context),
      body: _buildBody(context),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mController.dispose();
    super.dispose();
  }

  _buildBody(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _notice(),
          Expanded(
            child: TabBarView(
              children: _tabItem.map<Widget>((item) {
                return OrderListItemPage(arguments: item);
              }).toList(),
              controller: _mController,
            ),
          ),
        ],
      ),
    );
  }

  _notice() {
    if (_noticeListModel == null) {
      return Container();
    }
    return GestureDetector(
      child: Container(
        color: backLightYellow,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Image.asset(
              'assets/images/notice_icon.png',
              width: 14,
              height: 14,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                '${_noticeListModel!.content}',
                style: t14Orange,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Routers.push(Routers.webView, context,
            {'url': '${_noticeListModel!.targetUrl}'});
      },
    );
  }

  void _getNotice() async {
    var sp = await LocalStorage.sp;
    var object = sp!.get(LocalStorage.noticeList);
    if (object != null) {
      List? decode = json.decode(object as String);
      if (decode != null && decode.isNotEmpty) {
        for (var element in decode) {
          if (element['type'] == 2) {
            setState(() {
              _noticeListModel = NoticeListModel.fromJson(element);
            });
            break;
          }
        }
      }
    }
  }
}
