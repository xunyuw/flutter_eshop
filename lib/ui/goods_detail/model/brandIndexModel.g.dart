// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brandIndexModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandIndexModel _$BrandIndexModelFromJson(Map<String, dynamic> json) =>
    BrandIndexModel()
      ..extInfo = json['extInfo'] as String?
      ..hasMore = json['hasMore'] as bool?
      ..itemList = (json['itemList'] as List<dynamic>?)
          ?.map((e) => ItemListItem.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$BrandIndexModelToJson(BrandIndexModel instance) =>
    <String, dynamic>{
      'extInfo': instance.extInfo,
      'hasMore': instance.hasMore,
      'itemList': instance.itemList,
    };
