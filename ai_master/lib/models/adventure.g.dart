// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adventure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdventureImpl _$$AdventureImplFromJson(Map<String, dynamic> json) =>
    _$AdventureImpl(
      id: json['id'] as String,
      scenarioTitle: json['scenario_title'] as String,
      adventureTitle: json['adventure_title'] as String,
      progressIndicator: (json['progress_indicator'] as num?)?.toDouble(),
      gameState: json['game_state'] as String,
      lastPlayedDate: (json['last_played_date'] as num).toInt(),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AdventureImplToJson(_$AdventureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scenario_title': instance.scenarioTitle,
      'adventure_title': instance.adventureTitle,
      'progress_indicator': instance.progressIndicator,
      'game_state': instance.gameState,
      'last_played_date': instance.lastPlayedDate,
      'sync_status': instance.syncStatus,
    };
