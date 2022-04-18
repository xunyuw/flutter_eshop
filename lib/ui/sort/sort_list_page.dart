import 'package:flutter/material.dart';
import 'package:flutter_app/component/loading.dart';
import 'package:flutter_app/component/tab_app_bar.dart' as prefix0;
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/model/category.dart';
import 'package:flutter_app/ui/sort/model/sortListData.dart';
import 'package:flutter_app/ui/sort/sort_list_item_page.dart';

class SortListPage extends StatefulWidget {
  final Map? params;

  SortListPage({this.params});

  @override
  _SortChildState createState() => _SortChildState();
}

class _SortChildState extends State<SortListPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _firstLoading = true;

  int _activeIndex = 0;
  late TabController _mController;
  List<Category> _catalogList = [];
  int? _id = 0;

  @override
  void initState() {
    // TODO: implement initState
    _mController = TabController(length: _catalogList.length, vsync: this);
    super.initState();
    _id = widget.params!["subCategoryId"];
    _getInitData();
  }

  _getInitData() async {
    var responseData = await sortListData({
      "categoryType": "0",
      "subCategoryId": _id,
      "categoryId": widget.params!["categoryId"],
    });
    if (mounted) {
      var data = responseData.data;
      var sortListDataModel = SortListData.fromJson(data);

      setState(() {
        _catalogList = sortListDataModel.categoryL2List ?? [];
        _isLoading = false;

        if (_firstLoading) {
          for (int i = 0; i < (_catalogList.length); i++) {
            if (widget.params!['subCategoryId'] == _catalogList[i].id) {
              _activeIndex = i;
            }
          }
          _firstLoading = false;
        }
        _mController = TabController(
            length: _catalogList.length,
            vsync: this,
            initialIndex: _activeIndex);
      });
      _mController.addListener(() {
        setState(() {
          _activeIndex = _mController.index;
          _id = _catalogList[_activeIndex].id as int?;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String?> tabItem = [];
    for (int i = 0; i < (_catalogList.length); i++) {
      tabItem.add(_catalogList[i].name);
    }
    return Scaffold(
      backgroundColor: backColor,
      appBar: prefix0.TabAppBar(
        controller: _mController,
        tabs: tabItem,
        title: '${tabItem.length > 0 ? tabItem[_activeIndex] : ''}',
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
      color: backWhite,
      child: _isLoading
          ? Loading()
          : TabBarView(
              children: _catalogList.map((item) {
                return SortListItemPage(arguments: item);
              }).toList(),
              controller: _mController,
            ),
    );
  }
}
