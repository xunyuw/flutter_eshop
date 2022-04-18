// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category()
  ..id = json['id'] as num?
  ..superCategoryId = json['superCategoryId'] as num?
  ..showIndex = json['showIndex'] as num?
  ..picUrl = json['picUrl'] as String?
  ..categoryName = json['categoryName'] as String?
  ..targetUrl = json['targetUrl'] as String?
  ..showPicUrl = json['showPicUrl'] as String?
  ..wapBannerUrl = json['wapBannerUrl'] as String?
  ..name = json['name'] as String?
  ..frontName = json['frontName'] as String?
  ..itemPicBeanList = (json['itemPicBeanList'] as List<dynamic>?)
      ?.map((e) => ItemPicBeanList.fromJson(e as Map<String, dynamic>))
      .toList()
  ..bannerList = (json['bannerList'] as List<dynamic>?)
      ?.map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
      .toList()
  ..test = json['test'] as String?;

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'superCategoryId': instance.superCategoryId,
      'showIndex': instance.showIndex,
      'picUrl': instance.picUrl,
      'categoryName': instance.categoryName,
      'targetUrl': instance.targetUrl,
      'showPicUrl': instance.showPicUrl,
      'wapBannerUrl': instance.wapBannerUrl,
      'name': instance.name,
      'frontName': instance.frontName,
      'itemPicBeanList': instance.itemPicBeanList,
      'bannerList': instance.bannerList,
      'test': instance.test,
    };
