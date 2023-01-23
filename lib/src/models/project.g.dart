// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      company: json['company'] as String?,
    );

Map<String, dynamic> _$ProjectToJson(Project instance) {
  final val = <String, dynamic>{
    'project_id': instance.projectId,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('company', instance.company);
  return val;
}
