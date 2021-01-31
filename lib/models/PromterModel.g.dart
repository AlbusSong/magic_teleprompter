// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PromterModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromterModel _$PromterModelFromJson(Map<String, dynamic> json) {
  return PromterModel(
    json['id'] as int,
    json['title'] as String,
    json['content'] as String,
    json['status'] as int,
  );
}

Map<String, dynamic> _$PromterModelToJson(PromterModel instance) =>
    <String, dynamic>{
      'id': instance.the_id,
      'title': instance.title,
      'content': instance.content,
      'status': instance.status,
    };
