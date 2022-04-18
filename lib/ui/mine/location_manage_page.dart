import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/ui/component/simple_cupertino_dialog.dart';
import 'package:flutter_app/ui/mine/model/locationItemModel.dart';
import 'package:flutter_app/ui/router/router.dart';
import 'package:flutter_app/component/app_bar.dart';

///地址管理
class LocationManagePage extends StatefulWidget {
  @override
  _LocationManagePageState createState() => _LocationManagePageState();
}

class _LocationManagePageState extends State<LocationManagePage> {
  List<LocationItemModel> _locationList = [];
  num? _addressId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: '地址管理',
      ).build(context),
      body: Column(
        children: [
          Container(
            child: Image.asset('assets/images/address_line.png'),
          ),
          Expanded(child: _locations(context)),
          _addAddress(context)
        ],
      ),
    );
  }

  _locations(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _buildItem(context, index);
      },
      itemCount: _locationList.length,
    );
  }

  _buildItem(BuildContext context, int index) {
    var item = _locationList[index];

    Widget widget = Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 15),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: backGrey, width: 1))),
        padding: EdgeInsets.fromLTRB(0, 20, 15, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${item.name}',
                        style: t16black,
                      ),
                    ),
                    if (item.dft!)
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                            border: Border.all(color: redColor),
                            borderRadius: BorderRadius.circular(2)),
                        child: Text(
                          item.dft! ? '默认' : '',
                          style: TextStyle(
                              fontSize: 12, color: textRed, height: 1.1),
                        ),
                      )
                  ],
                )),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${item.mobile}',
                      style: t16black,
                    ),
                  ),
                  Text(
                    '${item.fullAddress}',
                    style: t14grey,
                  )
                ],
              ),
            ),
            IconButton(
                icon: Image.asset(
                  'assets/images/delete.png',
                  width: 22,
                  height: 22,
                ),
                onPressed: () {
                  setState(() {
                    _addressId = item.id;
                  });
                  _confirmDialog(context);
                })
          ],
        ),
      ),
    );

    return Routers.link(widget, Routers.addAddress, context, {'address': item},
        (value) {
      _getLocations();
    });
  }

  void _getLocations() async {
    var responseData = await getLocationList();
    if (mounted) {
      List data = responseData.data;
      List<LocationItemModel> dataList = [];
      data.forEach((element) {
        dataList.add(LocationItemModel.fromJson(element));
      });

      setState(() {
        _locationList = dataList;
      });
    }
  }

  void _deleteAddress() async {
    Map<String, dynamic> params = {'id': _addressId};
    await deleteAddress(params).then((value) {
      _getLocations();
    });
  }

  _confirmDialog(BuildContext context) {
    SimpleCupertinoDialog(
      tips: '确定删除该地址？',
      confirm: () {
        _deleteAddress();
      },
    ).build(context);
  }

  _addAddress(BuildContext context) {
    Widget widget = Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: backGrey,
          border: Border.all(color: redColor, width: 0.5),
          borderRadius: BorderRadius.circular(6)),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add,
            color: redColor,
            size: 14,
          ),
          Text(
            '新建地址',
            style: t16red,
          )
        ],
      ),
    );
    return Routers.link(widget, Routers.addAddress, context, null, (value) {
      _getLocations();
    });
  }
}
