// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goodDetailDownData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoodDetailDownData _$GoodDetailDownDataFromJson(Map<String, dynamic> json) =>
    GoodDetailDownData()
      ..id = json['id'] as num?
      ..html = json['html'] as String?
      ..attrList = (json['attrList'] as List<dynamic>?)
          ?.map((e) => AttrListItem.fromJson(e as Map<String, dynamic>))
          .toList()
      ..reportPicList = (json['reportPicList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..issueList = (json['issueList'] as List<dynamic>?)
          ?.map((e) => IssueListItem.fromJson(e as Map<String, dynamic>))
          .toList()
      ..name = json['name'] as String?
      ..desc = json['desc'] as String?
      ..pic = json['pic'] as String?
      ..itemSizeTableFlag = json['itemSizeTableFlag'] as bool?
      ..itemSizeTableDetailFlag = json['itemSizeTableDetailFlag'] as bool?
      ..updateTime = json['updateTime'] as num?;

Map<String, dynamic> _$GoodDetailDownDataToJson(GoodDetailDownData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'html': instance.html,
      'attrList': instance.attrList,
      'reportPicList': instance.reportPicList,
      'issueList': instance.issueList,
      'name': instance.name,
      'desc': instance.desc,
      'pic': instance.pic,
      'itemSizeTableFlag': instance.itemSizeTableFlag,
      'itemSizeTableDetailFlag': instance.itemSizeTableDetailFlag,
      'updateTime': instance.updateTime,
    };
