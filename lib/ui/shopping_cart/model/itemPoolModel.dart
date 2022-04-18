import 'package:flutter_app/model/itemListItem.dart';
import 'package:flutter_app/model/pagination.dart';
import 'package:flutter_app/ui/goods_detail/model/goodDetail.dart';
import 'package:flutter_app/ui/shopping_cart/model/carItem.dart';
import 'package:flutter_app/ui/sort/model/categoryL1Item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'itemPoolModel.g.dart';

@JsonSerializable()
class ItemPoolModel {
  List<CategorytListItem>? categorytList;
  SearcherItemListResult? searcherItemListResult;
  SearchParams? searchParams;
  ItemPoolModel();

  factory ItemPoolModel.fromJson(Map<String, dynamic> json) =>
      _$ItemPoolModelFromJson(json);
}

@JsonSerializable()
class CategorytListItem {
  CategoryL1Item? categoryVO;
  num? count;

  CategorytListItem();

  factory CategorytListItem.fromJson(Map<String, dynamic> json) =>
      _$CategorytListItemFromJson(json);
}

@JsonSerializable()
class SearcherItemListResult {
  Pagination? pagination;
  List<GoodDetail>? result;

  SearcherItemListResult();

  factory SearcherItemListResult.fromJson(Map<String, dynamic> json) =>
      _$SearcherItemListResultFromJson(json);
}

@JsonSerializable()
class SearchParams {
  String? resultKey;

  SearchParams();

  factory SearchParams.fromJson(Map<String, dynamic> json) =>
      _$SearchParamsFromJson(json);
}
