// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sortListData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SortListData _$SortListDataFromJson(Map<String, dynamic> json) => SortListData()
  ..categoryItems = json['categoryItems'] == null
      ? null
      : SortlistCategoryItem.fromJson(
          json['categoryItems'] as Map<String, dynamic>)
  ..categoryL2List = (json['categoryL2List'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$SortListDataToJson(SortListData instance) =>
    <String, dynamic>{
      'categoryItems': instance.categoryItems,
      'categoryL2List': instance.categoryL2List,
    };
