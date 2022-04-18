import 'dart:async';
import 'dart:convert';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/component/back_loading.dart';
import 'package:flutter_app/component/slivers.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/ui/component/simple_cupertino_dialog.dart';
import 'package:flutter_app/ui/component/webview_login_page.dart';
import 'package:flutter_app/ui/goods_detail/model/goodDetail.dart';
import 'package:flutter_app/ui/router/router.dart';
import 'package:flutter_app/ui/shopping_cart/components/add_good_size_widget.dart';
import 'package:flutter_app/ui/shopping_cart/components/cart_item_widget.dart';
import 'package:flutter_app/ui/shopping_cart/components/cart_navbar_widget.dart';
import 'package:flutter_app/ui/shopping_cart/components/empty_cart_widget.dart';
import 'package:flutter_app/ui/shopping_cart/components/shopping_buy_button.dart';
import 'package:flutter_app/ui/shopping_cart/components/shopping_cart_page_top_tips.dart';
import 'package:flutter_app/ui/shopping_cart/model/carItem.dart';
import 'package:flutter_app/ui/shopping_cart/model/cartItemListItem.dart';
import 'package:flutter_app/ui/shopping_cart/model/redeemModel.dart';
import 'package:flutter_app/ui/shopping_cart/model/shoppingCartModel.dart';
import 'package:flutter_app/utils/eventbus_constans.dart';
import 'package:flutter_app/utils/eventbus_utils.dart';
import 'package:flutter_app/utils/toast.dart';

import 'model/postageVO.dart';

class ShoppingCartPage extends StatefulWidget {
  final Map? params;

  const ShoppingCartPage({Key? key, this.params}) : super(key: key);

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage>
    with AutomaticKeepAliveClientMixin {
  /// 完整数据
  var _data;

  /// 有效的购物车组列表
  List<CarItem> _cartGroupList = [];

  ///包邮条件
  var _postageVO = PostageVO();

  /// 无效的购物车组列表
  List<CarItem> _invalidCartGroupList = [];

  /// 价格
  num _price = 0;

  /// 促销价
  num _promotionPrice = 0;

  /// 是否全部勾选选中
  bool _isCheckedAll = false;

  /// 是否全部勾选选中
  bool _isEditCheckedAll = false;

  /// 选中商品数量
  num _selectedNum = 0;

  /// 是否正在加载
  bool _loading = false;

  /// 是否正在编辑
  bool _isEdit = false;

  bool _isLogin = true;

  final _controller = TextEditingController();

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkLogin();
    HosEventBusUtils.on((dynamic event) {
      if (event == REFRESH_CART) {
        setState(() {
          _isEdit = false;
        });
        _checkLogin(showProgress: false);
      }
    });
  }

  ///检查是否登录
  _checkLogin({bool showProgress = true}) async {
    var responseData = await checkLogin();
    var isLogin = responseData.data;
    if (isLogin == null) {
      setState(() {
        _isLogin = false;
      });
    } else {
      setState(() {
        _isLogin = isLogin;
      });
      if (isLogin) {
        _getData(showProgress: showProgress);
        Timer(Duration(seconds: 1), () {
          HosEventBusUtils.fire(REFRESH_MINE);
          HosEventBusUtils.fire(REFRESH_CART_NUM);
        });
      }
    }
  }

  // 获取购物车数据
  void _getData({bool showProgress = true}) async {
    setState(() {
      _loading = showProgress;
    });
    var responseData = await shoppingCart();
    if (responseData.code == '200') {
      _data = responseData.data;
      if (_data != null) {
        _setData(_data);
      }
    }
  }

  void _setData(var data) {
    if (data == null) {
      _getData();
      return;
    }
    var shoppingCartModel = ShoppingCartModel.fromJson(data);
    setState(() {
      _loading = false;
      _cartGroupList = shoppingCartModel.cartGroupList ?? [];
      _postageVO = shoppingCartModel.postageVO ?? PostageVO();

      _invalidCartGroupList = shoppingCartModel.invalidCartGroupList ?? [];

      _price = shoppingCartModel.actualPrice ?? 0;
      _promotionPrice = shoppingCartModel.promotionPrice ?? 0;
    });
    if (_cartGroupList.length > 0) {
      _setCheckedNum();
    } else {
      _selectedNum = 0;
      _isCheckedAll = false;
    }
  }

  _setCheckedNum() {
    ///获取选择的数量
    num selectedNum = 0;

    ///判断是否全选
    bool isCheckedAll = true;
    _cartGroupList.forEach((element) {
      var cartItemList = element.cartItemList!;
      cartItemList.forEach((item) {
        if (item.checked!) {
          selectedNum += item.cnt as int;
        }
        if (_itemCanCheck(item)) {
          if (!item.checked!) {
            isCheckedAll = false;
          }
        }
      });
    });
    setState(() {
      _selectedNum = selectedNum;
      _isCheckedAll = isCheckedAll;
    });
  }

  ///可以被选择的条件
  _itemCanCheck(CartItemListItem item) {
    if ((item.limitPurchaseFlag! && (item.limitPurchaseCount! < item.cnt!)) ||
        item.preemptionStatus == 0 ||
        item.sellVolume! < item.cnt! ||
        item.sellVolume == 0 ||
        item.id == 0 ||
        item.type == 110) {
      return false;
    }
    return true;
  }

  /// 购物车 全选/不选 网络请求
  _checkAllOrNot() async {
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> params = {'isChecked': _isCheckedAll};
    var responseData = await shoppingCartCheck(params);
    _data = responseData.data;
    _setData(_data);
  }

  /// 购物车  某个勾选框 选/不选 请求
  _checkOne(CartItemListItem item) async {
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> params = {
      'source': item.source,
      'type': item.type,
      'skuId': item.skuId,
      'isChecked': !(item.checked ?? false),
      'extId': item.extId,
    };
    var responseData = await shoppingCartCheckOne(params);
    _data = responseData.data;
    _setData(_data);
  }

  /// 购物车  分组选择或不选
  _checkGroup(CarItem itemData) async {
    setState(() {
      _loading = true;
    });
    List skuList = [];
    var carItem = itemData.cartItemList;
    carItem!.forEach((element) {
      Map<String, dynamic> params = {
        'type': element.type,
        'skuId': element.skuId,
        'promId': itemData.promId,
        'gift': false,
        'addBuy': false,
        'extId': element.extId,
        'checked': !(itemData.checked ?? false)
      };
      skuList.add(params);
    });

    Map<String, dynamic> params = {'skuList': skuList};
    var responseData =
        await batchUpdateCheck({'selectedSku': json.encode(params)});
    _data = responseData.data;
    _setData(_data);
  }

  /// 购物车  商品 选购数量变化 请求
  _checkOneNum(CartItemListItem item, num cnt) async {
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> params = {
      'source': item.source,
      'type': item.type,
      'skuId': item.skuId,
      'cnt': cnt,
      'extId': item.extId,
    };
    var responseData = await shoppingCartCheckNum(params);
    if (responseData.code == '200') {
      _data = responseData.data;
      _setData(_data);
      refreshCartNum();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 购物车编辑删除
  void _deleteCart() async {
    List checkedList = [];
    _cartGroupList.forEach((element) {
      List<CartItemListItem> getGroupItemList = _getGroupItemList(element);
      for (var item in getGroupItemList) {
        if (item.editChecked ?? false) {
          var map = {
            "type": item.type,
            "promId": item.source,
            "addBuy": item.id == 0 ? true : false,
            "skuId": item.skuId,
            "extId": item.extId
          };
          checkedList.add(map);
        }
      }
    });

    _invalidCartGroupList.forEach((element) {
      List<CartItemListItem> getGroupItemList = _getGroupItemList(element);
      for (var item in getGroupItemList) {
        if (item.editChecked ?? false) {
          var map = {
            "type": item.type,
            "promId": item.source,
            "addBuy": item.id == 0 ? true : false,
            "skuId": item.skuId,
            "extId": item.extId
          };
          checkedList.add(map);
        }
      }
    });

    Map<String, dynamic> item = {"skuList": checkedList};
    Map<String, dynamic> params = {'selectedSku': json.encode(item)};
    var responseData = await deleteCart(params);
    if (responseData.code == "200") {
      _data = responseData.data;
      _setData(_data);
      refreshCartNum();
    }
  }

  ///清除无效商品/删除所选商品 type-0清除无效商品弹窗，1删除购物车所选商品弹窗，
  _showDeleteDialog(int type) {
    SimpleCupertinoDialog(
      tips: type == 0 ? '确定清除无效商品？' : '要删除所选商品？',
      confirm: () {
        if (type == 0) {
          _clearInvalid();
        } else {
          _deleteCart();
        }
      },
    ).build(context);
  }

  ///清除无效商品
  _clearInvalid() async {
    List invalidSku = [];
    _invalidCartGroupList.forEach((item) {
      var cartItemList = item.cartItemList!;
      cartItemList.forEach((element) {
        var map = {
          "type": element.type,
          "promId": item.promId,
          "skuId": element.skuId,
          "gift": false
        };
        invalidSku.add(map);
      });
    });
    var map = {'skuList': invalidSku};
    Map<String, dynamic> param = {'invalidSku': convert.jsonEncode(map)};
    var response = await clearInvalidItem(param);
    if (response.code == '200') {
      setState(() {
        _invalidCartGroupList = [];
      });
      refreshCartNum();
    }
  }

  /// 更新购物车数量
  void refreshCartNum() {
    HosEventBusUtils.fire(REFRESH_CART_NUM);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          SystemNavigator.pop();
        }
        return Future.value(false);
      },
      child: _buildShoppingCart(),
    );
  }

  _buildShoppingCart() {
    var argument = widget.params;
    return _isLogin ? _buildBody(argument, context) : _loginPage(context);
  }

  _buildBody(Map<dynamic, dynamic>? argument, BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 0.3,
        backgroundColor: Colors.white,
        centerTitle: false,
        toolbarHeight: 45,
        leadingWidth: 0,
        titleSpacing: 0,
        shadowColor: backColor,
        title: CartNavBarWidget(
          canBack: widget.params != null,
          isEdit: _isEdit,
          editPress: () {
            setState(() {
              _isEdit = !_isEdit;
              if (_isEdit) {
                _setEditCheckedDft();
              }
            });
          },
        ),
      ),
      body: Stack(
        children: [
          _data == null ? Loading() : _buildData(context),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBuy(),
          ),
          if (_loading) _pageLoading(),
        ],
      ),
    );
  }

  ///点击编辑，重置选中状态全部不选中
  _setEditCheckedDft() {
    setState(() {
      _isEditCheckedAll = false;

      ///设置有效商品全不选
      _cartGroupList.forEach((element) {
        element.editChecked = false;
        _setItemEditChecked(element, false);
      });

      ///设置无效商品全不选
      _invalidCartGroupList.forEach((element) {
        element.editChecked = false;
        _setItemEditChecked(element, false);
      });
    });
  }

  ///设置条目选中状态
  void _setItemEditChecked(CarItem itemData, bool editChecked) {
    var getGroupItemList = _getGroupItemList(itemData);
    for (var item in getGroupItemList) {
      item.editChecked = editChecked;
    }
  }

  /// （编辑状态下）点击group复选框
  _setEditGroupChecked(CarItem itemData, bool checked) {
    /// TODO 关联编辑选中状态 （CartItemWidget中）
    setState(() {
      _cartGroupList.forEach((element) {
        if (element.promId == itemData.promId) {
          element.editChecked = checked;
          _setItemEditChecked(element, checked);
        }
      });
    });
  }

  ///（编辑状态下）编辑状态单选某个商品
  _setEditItemChecked(CarItem itemData, CartItemListItem item, bool checked) {
    setState(() {
      _cartGroupList.forEach((element) {
        List<CartItemListItem> getGroupItemList = _getGroupItemList(element);

        for (var element_2 in getGroupItemList) {
          if (element_2.skuId == item.skuId) {
            element_2.editChecked = checked;
            break;
          }
        }
      });

      _invalidCartGroupList.forEach((element) {
        List<CartItemListItem> getGroupItemList = _getGroupItemList(element);

        for (var element_2 in getGroupItemList) {
          if (element_2.skuId == item.skuId) {
            element_2.editChecked = checked;
            break;
          }
        }
      });
    });

    ///判断group复选框是否全选
    setState(() {
      _cartGroupList.forEach((element) {
        bool isItemDataChecked = true;
        List<CartItemListItem> getGroupItemList = _getGroupItemList(element);

        for (var element_2 in getGroupItemList) {
          if (element_2.editChecked == null || !element_2.editChecked!) {
            isItemDataChecked = false;
            break;
          }
        }
        element.editChecked = isItemDataChecked;
      });
    });
  }

  ///编辑状态下全选/全不选
  _setEditCheckAll() {
    setState(() {
      ///设置有效商品全不选
      _cartGroupList.forEach((element) {
        element.editChecked = _isEditCheckedAll;
        _setItemEditChecked(element, _isEditCheckedAll);
      });

      ///设置无效商品全不选
      _invalidCartGroupList.forEach((element) {
        element.editChecked = _isEditCheckedAll;
        _setItemEditChecked(element, _isEditCheckedAll);
      });
    });
  }

  ///获取购物车有效展示条目（LIST）
  _getGroupItemList(CarItem itemData) {
    List<CartItemListItem> itemList = [];
    var cartItemList = itemData.cartItemList ?? [];

    List<AddBuyStepListItem> activityList = [];
    if (itemData.promType == 102) {
      ///满赠
      activityList = itemData.giftStepList ?? [];
    } else if (itemData.promType == 104) {
      ///换购
      activityList = itemData.addBuyStepList ?? [];
    } else if (itemData.promType == 4) {
      ///换购
      activityList = itemData.addBuyStepList ?? [];
    }

    if (activityList.isNotEmpty) {
      activityList.forEach((element_1) {
        ///TODO 102满赠,104换购,107满件减,108满额减,109满折(待补充),
        List<CartItemListItem> itemItemList = [];
        if (itemData.promType == 102) {
          itemItemList = element_1.giftItemList ?? [];
        } else if (itemData.promType == 4 || itemData.promType == 104) {
          itemItemList = element_1.addBuyItemList ?? [];
        }
        if (itemItemList.isNotEmpty) {
          itemItemList.forEach((element_2) {
            ///方便编辑添加check
            if (element_2.checked!) {
              itemList.add(element_2);
            }
          });
        }
      });
    }
    itemList.addAll(cartItemList);
    return itemList;
  }

  _pageLoading() {
    return Container(
      color: Colors.transparent,
      child: Loading(),
      width: double.infinity,
      height: double.infinity,
    );
  }

  _loginPage(BuildContext context) {
    return WebLoginWidget(
      onValueChanged: (value) {
        if (value) {
          setState(() {
            _isLogin = value;
          });
          _checkLogin();
        }
      },
    );
  }

  _buildData(BuildContext context) {
    return Positioned(
      bottom: 36,
      top: 0,
      left: 0,
      right: 0,
      child: _cartGroupList.isEmpty
          ? EmptyCartWidget()
          : CustomScrollView(
              slivers: [
                singleSliverWidget(_buildTopTips()),
                singleSliverWidget(_dataList()),
                singleSliverWidget(Container(height: 10)),
                singleSliverWidget(_invalidTitle()),
                singleSliverWidget(_invalidList()),
                singleSliverWidget(Container(height: 10)),
              ],
            ),
    );
  }

  _invalidTitle() {
    if (_invalidCartGroupList.isNotEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: lineColor, width: 0.3))),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '失效商品',
                style: t16black,
              ),
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: textBlack, width: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '清除失效商品',
                  style: t13black,
                ),
              ),
              onTap: () {
                _showDeleteDialog(0);
              },
            )
          ],
        ),
      );
    }
    return Container();
  }

  /// 导航下面，商品上面  标题部分
  _buildTopTips() {
    return TopTipsWidget(
        postageVO: _postageVO,
        callBack: () {
          _getData();
        });
  }

  /// 有效商品列表
  _dataList() {
    return CartItemWidget(
      controller: _controller,
      checkOne: (CartItemListItem item) {
        _checkOne(item);
      },
      checkGroup: (CarItem? itemData) {
        _checkGroup(itemData!);
      },
      deleteCheckItem: (CarItem itemData, CartItemListItem item, bool check) {
        _setEditItemChecked(itemData, item, check);
      },
      deleteCheckGroup: (CarItem itemData, bool check) {
        /// group选择
        _setEditGroupChecked(itemData, check);
      },
      numChange: (CartItemListItem item, num cnt) {
        _checkOneNum(item, cnt);
      },
      goRedeem: (CarItem itemData) {
        Routers.push(Routers.getCarsPage, context,
            {'data': itemData, 'promType': itemData.promType}, (value) {
          _getData();
        });
      },
      skuClick: (CartItemListItem item) {
        _getSkuClickGood(item);
      },
      isEdit: _isEdit,
      dataList: _cartGroupList,
      callBack: () {
        _getData();
      },
    );
  }

  _getSkuClickGood(CartItemListItem item) async {
    Map<String, dynamic> params = {
      'id': item.itemId,
      'extId': item.extId,
      'type': item.type,
      'promotionId': item.source,
      'skuId': item.skuId,
    };
    var responseData = await detailForCart(params);
    if (responseData.code == '200' && responseData.data != null) {
      var goodDetail = GoodDetail.fromJson(responseData.data);
      _buildSizeModel(context, item, goodDetail);
    }
  }

  ///属性选择底部弹窗
  _buildSizeModel(
      BuildContext context, CartItemListItem item, GoodDetail detail) {
    //底部弹出框,背景圆角的话,要设置全透明,不然会有默认你的白色背景
    return showModalBottomSheet(
      //设置true,不会造成底部溢出
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddGoodSizeWidget(
          goodDetail: detail,
          skuId: item.skuId,
          extId: item.extId,
          type: item.type,
          cnt: item.cnt,
          updateSkuSuccess: () {
            _getData();
          },
        );
      },
    );
  }

  // 无效商品列表
  _invalidList() {
    return CartItemWidget(
      controller: _controller,
      checkOne: (CartItemListItem item) {
        _checkOne(item);
      },
      checkGroup: (CarItem? itemData) {
        _checkGroup(itemData!);
      },
      deleteCheckItem: (CarItem itemData, CartItemListItem item, bool check) {
        _setEditItemChecked(itemData, item, check);
      },
      deleteCheckGroup: (CarItem itemData, bool check) {
        /// group选择
        _setEditGroupChecked(itemData, check);
      },
      numChange: (CartItemListItem item, num? cnt) {
        _checkOneNum(item, cnt!);
      },
      goRedeem: (CarItem itemData) {
        Routers.push(Routers.getCarsPage, context,
            {'data': itemData, 'promType': itemData.promType}, (value) {
          _getData();
        });
      },
      skuClick: (CartItemListItem item) {
        _getSkuClickGood(item);
      },
      isEdit: _isEdit,
      dataList: _invalidCartGroupList,
      isInvalid: true,
      callBack: () {
        _getData();
      },
    );
  }

  /// 底部 商品勾选状态、价格信息、下单 部分
  _buildBuy() {
    if (_cartGroupList.isEmpty) {
      return Container();
    }
    return ShoppingBuyButton(
      price: _price,
      promotionPrice: _promotionPrice,
      isCheckedAll: _isCheckedAll,
      isEditCheckedAll: _getEditSelectedNum()[2],
      isEdit: _isEdit,
      selectedNum: _selectedNum,
      editSelectedNum: _getEditSelectedNum()[1],
      checkAll: (bool) {
        setState(() {
          _isCheckedAll = !_isCheckedAll;
          _checkAllOrNot();
        });
      },
      editCheckAll: (bool) {
        setState(() {
          _isEditCheckedAll = !_isEditCheckedAll;
          _setEditCheckAll();
        });
      },
      editDelete: () {
        ///删除所选
        _showDeleteDialog(1);
      },
    );
  }

  ///获取编辑状态下选择数量，购物车数量
  _getEditSelectedNum() {
    num selectNum = 0;
    num allCartNum = 0;
    bool isEditSelectedAll = false;
    _cartGroupList.forEach((element) {
      List<CartItemListItem> getGroupItemList = _getGroupItemList(element);
      for (var item in getGroupItemList) {
        if (item.editChecked ?? false) {
          selectNum += item.cnt ?? 0;
        }
        allCartNum += item.cnt ?? 0;
      }
    });

    _invalidCartGroupList.forEach((element) {
      List<CartItemListItem> getGroupItemList = _getGroupItemList(element);
      for (var item in getGroupItemList) {
        if (item.editChecked ?? false) {
          selectNum += item.cnt ?? 0;
        }
        allCartNum += item.cnt ?? 0;
      }
    });
    if (selectNum == allCartNum) {
      isEditSelectedAll = true;
    }
    return [allCartNum, selectNum, isEditSelectedAll];
  }

  // 分割线
  Widget line = Container(
    height: 10,
    color: Color(0xFFEAEAEA),
  );

  @override
  void dispose() {
    // TODO: implement dispose
    HosEventBusUtils.off();
    _controller.dispose();
    super.dispose();
  }

  void _goPay() async {
    var responseData = await checkLogin();
    var isLogin = responseData.data;
    if (!isLogin) {
      return;
    }

    ///组装数据
    List cartGroupList = [];

    _cartGroupList.forEach((cartGroupItem) {
      List cartItemListData = [];
      List addBuyItemListData = [];

      Map<String, dynamic> map = {
        'promId': cartGroupItem.promId,
        'suitCount': cartGroupItem.suitCount,
        'promSatisfy': cartGroupItem.promSatisfy,
        'giftItemList': []
      };

      ///购物车列表
      var cartItemList = cartGroupItem.cartItemList;
      if (cartItemList != null && cartItemList.isNotEmpty) {
        cartItemList.forEach((cartItemListItem) {
          if (cartItemListItem.checked!) {
            var map = {
              'id':
                  '${cartItemListItem.source}_${cartItemListItem.skuId}_${cartItemListItem.preSellStatus}_${cartItemListItem.status}',
              'uniqueKey': cartItemListItem.uniqueKey,
              'skuId': cartItemListItem.skuId,
              'count': cartItemListItem.cnt,
              'source': cartItemListItem.source,
              'sources': cartItemListItem.sources,
              'isPreSell': cartItemListItem.preSellStatus == 0 ? false : true,
              'extId': cartItemListItem.extId,
              'type': cartItemListItem.type,
              'checkExt': cartItemListItem.checkExt
            };
            cartItemListData.add(map);
          }
        });
      }

      ///换购商品列表
      var addBuyStepList = cartGroupItem.addBuyStepList;
      if (addBuyStepList != null && addBuyStepList.isNotEmpty) {
        addBuyStepList.forEach((addBuyStepListItem) {
          var addBuyItemList = addBuyStepListItem.addBuyItemList;
          if (addBuyItemList != null && addBuyItemList.isNotEmpty) {
            addBuyItemList.forEach((addBuyItemListItem) {
              if (addBuyItemListItem.checked!) {
                var map = {
                  'id':
                      '${addBuyItemListItem.source}_${addBuyItemListItem.skuId}_${addBuyItemListItem.preSellStatus}_${addBuyItemListItem.status}',
                  'uniqueKey': addBuyItemListItem.uniqueKey,
                  'skuId': addBuyItemListItem.skuId,
                  'count': addBuyItemListItem.cnt,
                  'source': addBuyItemListItem.source,
                  'sources': addBuyItemListItem.sources,
                  'isPreSell':
                      addBuyItemListItem.preSellStatus == 0 ? false : true,
                  'extId': addBuyItemListItem.extId,
                  'type': addBuyItemListItem.type,
                  'checkExt': addBuyItemListItem.checkExt
                };
                addBuyItemListData.add(map);
              }
            });
          }
        });
      }

      map['cartItemList'] = cartItemListData;
      map['addBuyItemList'] = addBuyItemListData;

      cartGroupList.add(map);
    });

    var orderCart = {'cartGroupList': cartGroupList};
    Map<String, dynamic> postParams = {'orderCart': orderCart};
    // var response = await checkBeforeInit(postParams);
    // Routers.push(Routers.orderInit, context, {'data': orderCart});
  }
}
