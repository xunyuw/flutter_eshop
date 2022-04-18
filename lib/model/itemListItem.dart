import 'package:flutter_app/model/finalPriceInfoVO.dart';
import 'package:flutter_app/model/itemTagListItem.dart';
import 'package:flutter_app/model/topLogo.dart';
import 'package:flutter_app/ui/goods_detail/model/skuSpecListItem.dart';
import 'package:flutter_app/ui/home/model/hotSaleListBottomInfo.dart';
import 'package:flutter_app/ui/sort/model/listPromBanner.dart';
import 'package:json_annotation/json_annotation.dart';

part 'itemListItem.g.dart';

@JsonSerializable()
class ItemListItem {
  num? id;
  String? listPicUrl;
  String? name;
  String? seoTitle;
  String? simpleDesc;
  String? primaryPicUrl;
  String? productPlace;
  num? counterPrice;
  num? primarySkuId;
  num? retailPrice;
  num? status;
  num? colorNum;
  String? promDesc;
  bool? soldOut;
  bool? underShelf;
  String? scenePicUrl;
  String? promTag;
  String? goodCmtRate;
  HotSaleListBottomInfo? hotSaleListBottomInfo;

  List<ItemTagListItem>? itemTagList;
  ListPromBanner? listPromBanner;
  List<SkuSpecListItem>? skuSpecList;
  FinalPriceInfoVO? finalPriceInfoVO;

  TopLogo? topLogo;

  ///新品首发中使用
  num? sortOriginPrice;

  ItemListItem();

  factory ItemListItem.fromJson(Map<String, dynamic> json) =>
      _$ItemListItemFromJson(json);
}
