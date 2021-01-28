import 'package:json_annotation/json_annotation.dart';

part 'PromterModel.g.dart';

@JsonSerializable()
class PromterModel extends Object {
  @JsonKey(name: 'id')
  int the_id;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'status')
  int status;

  PromterModel(
    this.the_id,
    this.title,
    this.content,
    this.status,
  );

  factory PromterModel.fromJson(Map<String, dynamic> srcJson) =>
      _$PromterModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PromterModelToJson(this);
}
