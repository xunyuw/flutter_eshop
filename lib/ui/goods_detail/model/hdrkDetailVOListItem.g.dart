// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hdrkDetailVOListItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HdrkDetailVOListItem _$HdrkDetailVOListItemFromJson(
        Map<String, dynamic> json) =>
    HdrkDetailVOListItem()
      ..id = json['id'] as num?
      ..name = json['name'] as String?
      ..promLimitDesc = json['promLimitDesc'] as String?
      ..activityType = json['activityType'] as String?
      ..huodongUrlWap = json['huodongUrlWap'] as String?
      ..startTime = json['startTime'] as num?
      ..endTime = json['endTime'] as num?
      ..promotionType = json['promotionType'] as num?
      ..canUseCoupon = json['canUseCoupon'] as bool?;

Map<String, dynamic> _$HdrkDetailVOListItemToJson(
        HdrkDetailVOListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'promLimitDesc': instance.promLimitDesc,
      'activityType': instance.activityType,
      'huodongUrlWap': instance.huodongUrlWap,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'promotionType': instance.promotionType,
      'canUseCoupon': instance.canUseCoupon,
    };
