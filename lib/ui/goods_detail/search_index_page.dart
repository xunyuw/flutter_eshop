import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/model/itemListItem.dart';
import 'package:flutter_app/ui/component/menu_pop_widget.dart';
import 'package:flutter_app/ui/goods_detail/model/searchInitModel.dart';
import 'package:flutter_app/ui/component/model/searchParamModel.dart';
import 'package:flutter_app/ui/router/router.dart';
import 'package:flutter_app/ui/sort/component/good_items.dart';
import 'package:flutter_app/ui/sort/model/categoryL1Item.dart';
import 'package:flutter_app/ui/sort/model/searchResultModel.dart';
import 'package:flutter_app/utils/local_storage.dart';
import 'package:flutter_app/utils/util_mine.dart';
import 'package:flutter_app/component/floating_action_button.dart';
import 'package:flutter_app/component/global.dart';
import 'package:flutter_app/ui/goods_detail/components/search_widget.dart';
import 'package:flutter_app/component/sliver_footer.dart';

class SearchIndexPage extends StatefulWidget {
  final Map? params;

  SearchIndexPage({this.params});

  @override
  _SearchIndexPageState createState() => _SearchIndexPageState();
}

class _SearchIndexPageState extends State<SearchIndexPage> {
  late TextEditingController _controller;
  final _scrollController = new ScrollController();
  String? _textValue = '';

  var _keywordList = [];
  List<dynamic> _hotKeyWordList = [];

  ///分类
  List<CategoryL1Item> _categoryL1List = [];

  ///搜索提示
  List<dynamic> _searchTipsData = [];

  var _isSearchResult = false;

  //初始化,状态
  var _isFirstLoading = true;
  var _bottomTipsText = '';

  //请求是以这个参数为加载更多
  var _paeSize = 40;
  var _itemId = 0;

  ///搜索高度
  final _searchHeight = 48.0;

  var _searchModel = SearchParamModel();

  ///搜索结果
  List<ItemListItem> _directlyList = [];
  bool _hasMore = false;

  bool _noData = false;

  final _streamController = StreamController<bool>.broadcast();

  @override
  void initState() {
    // TODO: implement initState
    // setState(() {
    //   if (widget.params != null) {
    //     _textValue = widget.params!['id'];
    //   }
    // });
    super.initState();
    _setTextEditingController();
    _scrollController.addListener(_scrollerListener);
    _getKeyword();
    _searchInit();
  }

  _setTextEditingController() {
    _controller = TextEditingController.fromValue(TextEditingValue(
        // 设置内容
        text: _textValue!,
        // 保持光标在最后
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: _textValue!.length))));
  }

  void _scrollerListener() {
    // 如果下拉的当前位置到scroll的最下面
    if (_scrollController.position.pixels > 700) {
      _streamController.sink.add(true);
    } else {
      _streamController.sink.add(false);
    }
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore) {
        _getTipsResult(false);
      }
    }
  }

  void _searchInit() async {
    var responseData = await searchInit();
    if (mounted) {
      if (responseData.code == '200') {
        var searchInitModel = SearchInitModel.fromJson(responseData.data);
        if (searchInitModel.hotKeywordVOList != null) {
          setState(() {
            _hotKeyWordList = searchInitModel.hotKeywordVOList!;
          });
        }
      }
    }
  }

  void _resetPage() {
    setState(() {
      _directlyList = [];
    });
    _getTipsResult(true);
  }

  void _getTipsResult(bool showProgress) async {
    var params = {
      '_stat_search': _searchModel.statSearch,
      'keyword': _searchModel.keyWord,
      'sortType': _searchModel.sortType,
      'descSorted': _searchModel.descSorted ?? false,
      'categoryId': _searchModel.categoryId,
      'matchType': _searchModel.matchType,
      'floorPrice': _searchModel.floorPrice,
      'upperPrice': _searchModel.upperPrice,
      'size': _paeSize,
      'itemId': _itemId,
      'stillSearch': _searchModel.stillSearch,
      'searchWordSource': _searchModel.searchWordSource,
      'needPopWindow': _searchModel.needPopWindow
    };

    setState(() {
      if (showProgress) {
        _noData = false;
        _isFirstLoading = true;
      } else {
        _isFirstLoading = false;
      }
    });

    if (_searchModel.descSorted != null) {
      params.addAll({'descSorted': _searchModel.descSorted});
    }
    var responseData = await searchSearch(params, showProgress: showProgress);

    if (mounted) {
      var data = responseData.data;
      if (data == null) {
        setState(() {
          if (_isFirstLoading) {
            _noData = true;
          }
        });
      }
      if (responseData.code == '200') {
        var searchResultModel = SearchResultModel.fromJson(data);
        setState(() {
          var directlyList = searchResultModel.directlyList;
          _categoryL1List = searchResultModel.categoryL1List ?? [];
          _hasMore = searchResultModel.hasMore ?? false;
          if (directlyList == null || directlyList.isEmpty) {
            _bottomTipsText = '没有找到您想要的内容';
            if (_isFirstLoading) {
              _noData = true;
            }
          } else {
            _directlyList.addAll(directlyList);
            if (!_hasMore) {
              _bottomTipsText = '没有更多了';
            }
            _isSearchResult = true;
          }
        });
      }
    }
  }

  void _getSearchTips() async {
    Map<String, dynamic> params = {'keywordPrefix': _textValue};
    var responseData = await searchTips(params);
    if (mounted) {
      if (responseData.data != null) {
        setState(() {
          _searchTipsData = responseData.data;
          _isSearchResult = false;
          _hasMore = false;
          if (_searchTipsData.length == 0) {
            _bottomTipsText = '暂时没有您想要的内容';
          } else {
            _bottomTipsText = '';
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_noData && _controller.text.isNotEmpty)
            Center(child: Text('抱歉，没有找到符合条件的商品\n建议修改筛选条件重新查找')),
          _searchInitWidget(context),
          _controller.text == '' ? Container() : _showResult(),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: SearchWidget(
              searchHeight: _searchHeight,
              hintText: '请输入商品名称',
              controller: _controller,
              onValueChangedCallBack: (value) {
                setState(() {
                  _textValue = value;
                  if (value == '') {
                    _directlyList = [];
                  }
                });
                if (value == '') {
                  _controller.text = '';
                } else {
                  _getSearchTips();
                }
              },
              onBtnClick: (value) {
                Navigator.pop(context);
              },
              onSubmitted: (value) {
                _getTipsResult(true);
              },
            ),
          ),
          if (_isSearchResult && _controller.text != '')
            Positioned(
              top: MediaQuery.of(context).padding.top + _searchHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: MenuPopWidget(
                searchParamModel: _searchModel,
                categorytList: _categoryL1List,
                menuChange: (searchModel) {
                  setState(() {
                    _searchModel = searchModel!;
                  });
                  _resetPage();
                },
              ),
            ),
        ],
      ),
      floatingActionButton: StreamBuilder(
          stream: _streamController.stream,
          initialData: false,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return snapshot.data! ? floatingAB(_scrollController) : Container();
          }),
    );
  }

  _searchInitWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(height: _searchHeight),
        Container(
          color: backWhite,
          padding: EdgeInsets.fromLTRB(
              10, MediaQuery.of(context).padding.top + 15, 10, 10),
          // padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 15), 10, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  '历史记录',
                  style: t14grey,
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    _clearKeyword();
                  },
                  child: Image.asset(
                    'assets/images/delete.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
          color: backWhite,
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 5,
            runSpacing: 10,
            children: _historyItem(context),
          ),
        ),
        Container(
          color: backWhite,
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          alignment: Alignment.centerLeft,
          child: Text(
            '热门搜索',
            style: t14grey,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
          color: backWhite,
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 5,
            runSpacing: 10,
            children: _hotItem(context),
          ),
        ),
      ],
    );
  }

  _showResult() {
    return Container(
      color: backWhite,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              _searchHeight +
              (_isSearchResult ? 35 : 0)),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          _isSearchResult
              ? GoodItems(dataList: _directlyList)
              : _buildSearchTips(),
          SliverFooter(hasMore: _hasMore, tipsText: _bottomTipsText),
        ],
      ),
    );
  }

  _buildSearchTips() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        Widget widget = Container(
            margin: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.5, color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${_searchTipsData[index]}',
                    textAlign: TextAlign.start,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: arrowRightIcon,
                )
              ],
            ));
        return GestureDetector(
          child: widget,
          onTap: () {
            setState(() {
              _searchModel.keyWord = _searchTipsData[index];
              _searchModel.searchWordSource = 7;
              _searchModel.statSearch = 'autoComplete';
              _searchResult();
              _getKeyword();
            });
          },
        );
      }, childCount: _searchTipsData.length),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 8,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0),
    );
  }

  void _searchResult() {
    _directlyList = [];
    Util.hideKeyBord(context);
    _saveKey(_searchModel.keyWord);
    _controller.text = _searchModel.keyWord!;
    _getTipsResult(true);
  }

  ///本地存储keyword
  void _saveKey(String? key) async {
    var sp = await LocalStorage.sp;
    var keywordStr = sp?.getString(LocalStorage.keyWord);
    if (keywordStr != null) {
      List<String?> split = keywordStr.split(';');
      if (split.indexOf(key) == -1) {
        sp!.setString(LocalStorage.keyWord, keywordStr + ';$key');
      }
    } else {
      sp!.setString(LocalStorage.keyWord, '$key');
    }
  }

  _clearKeyword() async {
    var sp = await LocalStorage.sp;
    sp!.remove(LocalStorage.keyWord);
    _getKeyword();
  }

  void _getKeyword() async {
    var sp = await LocalStorage.sp;
    var keyword = sp!.getString(LocalStorage.keyWord);
    if (keyword != null && keyword != '') {
      var split = keyword.split(';');
      // split.removeAt(0);
      var reversed = split.reversed.toList();
      setState(() {
        _keywordList = reversed;
      });
    } else {
      setState(() {
        _keywordList = [];
      });
    }
  }

  _historyItem(BuildContext context) {
    return _keywordList
        .map((value) => GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: textLightGrey, width: 0.5)),
                child: Text(
                  '$value',
                  style: t12black,
                ),
              ),
              onTap: () {
                setState(() {
                  _searchModel.keyWord = value;
                  _searchModel.searchWordSource = 5;
                  _searchModel.statSearch = 'history';
                  _searchResult();
                });
              },
            ))
        .toList();
  }

  _hotItem(BuildContext context) {
    return _hotKeyWordList
        .map(
          (value) => GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                      color: value.highlight == 1 ? textRed : textLightGrey,
                      width: 0.5)),
              child: Text(
                '${value.keyword}',
                style: value.highlight == 1 ? t12red : t12black,
              ),
            ),
            onTap: () {
              if (value.schemeUrl != null) {
                Routers.push(
                    Routers.webView, context, {'url': '${value.schemeUrl}'});
              } else {
                setState(() {
                  _searchModel.keyWord = value.keyword;
                });
                _searchResult();
              }
            },
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _streamController.close();
  }
}
