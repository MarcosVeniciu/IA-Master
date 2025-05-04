// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      adventureId: json['adventureId'] as String,
      sender: json['sender'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adventureId': instance.adventureId,
      'sender': instance.sender,
      'content': instance.content,
      'timestamp': instance.timestamp,
      'syncStatus': instance.syncStatus,
    };
