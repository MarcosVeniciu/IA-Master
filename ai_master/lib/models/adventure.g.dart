// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adventure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdventureImpl _$$AdventureImplFromJson(Map<String, dynamic> json) =>
    _$AdventureImpl(
      id: json['id'] as String,
      scenarioTitle: json['scenarioTitle'] as String,
      progressIndicator: (json['progressIndicator'] as num?)?.toDouble(),
      gameState: json['gameState'] as String,
      lastPlayedDate: (json['lastPlayedDate'] as num).toInt(),
      syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AdventureImplToJson(_$AdventureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scenarioTitle': instance.scenarioTitle,
      'progressIndicator': instance.progressIndicator,
      'gameState': instance.gameState,
      'lastPlayedDate': instance.lastPlayedDate,
      'syncStatus': instance.syncStatus,
      'messages': instance.messages,
    };
