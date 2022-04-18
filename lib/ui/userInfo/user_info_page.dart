import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/component/app_bar.dart';
import 'package:flutter_app/component/button_widget.dart';
import 'package:flutter_app/component/check_box.dart';
import 'package:flutter_app/component/global.dart';
import 'package:flutter_app/component/normal_textfiled.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/ui/router/router.dart';
import 'package:flutter_app/ui/userInfo/model/userInfoModel.dart';
import 'package:flutter_app/utils/toast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage>
    with WidgetsBindingObserver {
  String _userIcon =
      'https://yanxuan.nosdn.127.net/8945ae63d940cc42406c3f67019c5cb6.png';

  var _userInfoModel = UserInfoModel();
  final _nameController = TextEditingController();

  int? _sex = 0;

  String _bYear = '';
  String _bMonth = '';
  String _bDay = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _getUserInfo();
  }

  void _getUserInfo() async {
    var responseData = await ucenterInfo();
    if (mounted) {
      setState(() {
        _userInfoModel = UserInfoModel.fromJson(responseData.data);
        var user = _userInfoModel.user!;
        _nameController.text = user.nickname!;
        _sex = user.gender as int?;
        if (user.birthYear != 0) {
          _bYear = user.birthYear.toString();
          _bMonth = user.birthMonth.toString();
          _bDay = user.birthDay.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(title: '个人信息').build(context),
      body: _buildBody(context),
    );
  }

  Stack _buildBody(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 45,
          left: 0,
          right: 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildUserIcon(),
                SizedBox(height: 10),
                _buildId(),
                _buildAccount(),
                _buildNickame(),
                _buildSexy(),
                _buildBirthday(),
                _favorite(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              width: double.infinity,
              color: backWhite,
              child: Row(
                children: [
                  Expanded(
                      child: NormalBtn('取消', backWhite, () {
                    Navigator.pop(context);
                  }, textStyle: t14grey)),
                  Expanded(
                      child: NormalBtn('保存', backRed, () {
                    _saveDetail();
                  })),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildUserIcon() {
    return Container(
      color: backWhite,
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80),
            border: Border.all(color: lineColor, width: 1),
            image: DecorationImage(
              image:
                  NetworkImage('${_userInfoModel.user!.avatar ?? _userIcon}'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  _buildId() {
    return Container(
      decoration: BoxDecoration(
          color: backWhite,
          border: Border(bottom: BorderSide(color: lineColor, width: 0.5))),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('用户ID'),
          ),
          Expanded(
            flex: 2,
            child: Text('${_userInfoModel.user!.id}'),
          )
        ],
      ),
    );
  }

  _buildAccount() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            color: backWhite,
            border: Border(bottom: BorderSide(color: lineColor, width: 0.5))),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text('账号关联'),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: Text(
                  '${_userInfoModel.user!.aliases!.length}个',
                ),
              ),
            ),
            arrowRightIcon
          ],
        ),
      ),
      onTap: () {
        return Routers.push(Routers.mineItems, context, {'id': 1});
      },
    );
  }

  _buildNickame() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: backWhite,
          border: Border(bottom: BorderSide(color: lineColor, width: 0.5))),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('昵称'),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 50,
              child: NormalTextFiled(
                controller: _nameController,
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildSexy() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: backWhite,
          border: Border(bottom: BorderSide(color: lineColor, width: 0.5))),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('性别'),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                MCheckBox(
                  suffixText: '男',
                  check: _sex == 0,
                  onPress: () {
                    setState(() {
                      _sex = 0;
                    });
                  },
                ),
                SizedBox(
                  width: 25,
                ),
                MCheckBox(
                  suffixText: '女',
                  check: _sex == 1,
                  onPress: () {
                    setState(() {
                      _sex = 1;
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildBirthday() {
    return GestureDetector(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: backWhite,
            border: Border(bottom: BorderSide(color: lineColor, width: 0.5))),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text('出生日期'),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: Text('$_bYear-$_bMonth-$_bDay'),
              ),
            ),
            arrowRightIcon
          ],
        ),
      ),
      onTap: () {
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(1980, 1, 31),
            maxTime: DateTime(2021, 1, 31),
            theme: DatePickerTheme(
                headerColor: backWhite,
                backgroundColor: backWhite,
                itemStyle: t14black,
                doneStyle: t14black,
                cancelStyle: t14grey),
            onChanged: (date) {}, onConfirm: (DateTime date) {
          setState(() {
            _bYear = date.year.toString();
            _bMonth = date.month.toString();
            _bDay = date.day.toString();
          });
        }, currentTime: DateTime.now(), locale: LocaleType.zh);
      },
    );
  }

  _favorite() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            color: backWhite,
            border: Border(bottom: BorderSide(color: lineColor, width: 0.5))),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text('感兴趣的分类'),
            ),
            arrowRightIcon
          ],
        ),
      ),
      onTap: () {
        Routers.push(Routers.favorite, context);
      },
    );
  }

  _saveDetail() async {
    var params = {
      'nickname': _nameController.text,
      'gender': '$_sex',
      'birthYear': '$_bYear',
      'birthMonth': '$_bMonth',
      'birthDay': '$_bDay',
    };
    var responseData = await saveUserInfo(params);
    if (responseData.code == '200') {
      Toast.show('保存成功', context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed) {
      FocusScope.of(context).unfocus();
    } else if (state == AppLifecycleState.detached) {
      FocusScope.of(context).unfocus();
    }

    print('---------------${state}');
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
