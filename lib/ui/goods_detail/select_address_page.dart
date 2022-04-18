import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/ui/mine/model/locationItemModel.dart';
import 'package:flutter_app/component/app_bar.dart';

@Deprecated('no used')
class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({Key? key}) : super(key: key);

  @override
  _SelectAddressPageState createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  List<LocationItemModel> _locationList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocations();
  }

  void _getLocations() async {
    var responseData = await getLocationList();
    List data = responseData.data;
    List<LocationItemModel> dataList = [];
    data.forEach((element) {
      dataList.add(LocationItemModel.fromJson(element));
    });

    setState(() {
      _locationList = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(Container(
      child: Image.asset('assets/images/address_line.png'),
    ));
    var list = _locationList.map<Widget>((item) => _buildItem(item)).toList();
    widgets.addAll(list);
    return Scaffold(
      appBar: TopAppBar(title: '配送至').build(context),
      body: Column(children: widgets),
    );
  }

  _buildItem(LocationItemModel item) {
    return GestureDetector(
      child: Container(
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
                      item.dft == true
                          ? Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: redColor),
                                  borderRadius: BorderRadius.circular(2)),
                              child: Text(
                                item.dft! ? '默认' : '',
                                style: t12red,
                              ),
                            )
                          : Container(
                              width: 45,
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
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context, item);
      },
    );
  }
}
