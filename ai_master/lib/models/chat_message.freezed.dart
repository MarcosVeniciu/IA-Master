// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  /// Identificador único da mensagem (UUID).
  String get id => throw _privateConstructorUsedError;

  /// Identificador da aventura à qual esta mensagem pertence (Chave Estrangeira).
  String get adventureId => throw _privateConstructorUsedError;

  /// O remetente da mensagem.
  ///
  /// Valores comuns: 'player', 'ai', 'system'.
  String get sender => throw _privateConstructorUsedError;

  /// O conteúdo textual da mensagem.
  String get content => throw _privateConstructorUsedError;

  /// Timestamp da criação da mensagem.
  /// Armazenado como milissegundos desde a época (Unix epoch).
  int get timestamp => throw _privateConstructorUsedError;

  /// Status de sincronização da mensagem com um backend (se aplicável).
  ///
  /// Valores possíveis:
  /// - 0: Apenas local, não sincronizado.
  /// - 1: Sincronizando.
  /// - 2: Sincronizado com sucesso.
  /// - -1: Erro durante a sincronização.
  int get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String adventureId,
    String sender,
    String content,
    int timestamp,
    int syncStatus,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? adventureId = null,
    Object? sender = null,
    Object? content = null,
    Object? timestamp = null,
    Object? syncStatus = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            adventureId:
                null == adventureId
                    ? _value.adventureId
                    : adventureId // ignore: cast_nullable_to_non_nullable
                        as String,
            sender:
                null == sender
                    ? _value.sender
                    : sender // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as int,
            syncStatus:
                null == syncStatus
                    ? _value.syncStatus
                    : syncStatus // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String adventureId,
    String sender,
    String content,
    int timestamp,
    int syncStatus,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? adventureId = null,
    Object? sender = null,
    Object? content = null,
    Object? timestamp = null,
    Object? syncStatus = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        adventureId:
            null == adventureId
                ? _value.adventureId
                : adventureId // ignore: cast_nullable_to_non_nullable
                    as String,
        sender:
            null == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as int,
        syncStatus:
            null == syncStatus
                ? _value.syncStatus
                : syncStatus // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl extends _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.adventureId,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.syncStatus = 0,
  }) : super._();

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  /// Identificador único da mensagem (UUID).
  @override
  final String id;

  /// Identificador da aventura à qual esta mensagem pertence (Chave Estrangeira).
  @override
  final String adventureId;

  /// O remetente da mensagem.
  ///
  /// Valores comuns: 'player', 'ai', 'system'.
  @override
  final String sender;

  /// O conteúdo textual da mensagem.
  @override
  final String content;

  /// Timestamp da criação da mensagem.
  /// Armazenado como milissegundos desde a época (Unix epoch).
  @override
  final int timestamp;

  /// Status de sincronização da mensagem com um backend (se aplicável).
  ///
  /// Valores possíveis:
  /// - 0: Apenas local, não sincronizado.
  /// - 1: Sincronizando.
  /// - 2: Sincronizado com sucesso.
  /// - -1: Erro durante a sincronização.
  @override
  @JsonKey()
  final int syncStatus;

  @override
  String toString() {
    return 'ChatMessage(id: $id, adventureId: $adventureId, sender: $sender, content: $content, timestamp: $timestamp, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.adventureId, adventureId) ||
                other.adventureId == adventureId) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    adventureId,
    sender,
    content,
    timestamp,
    syncStatus,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage extends ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String adventureId,
    required final String sender,
    required final String content,
    required final int timestamp,
    final int syncStatus,
  }) = _$ChatMessageImpl;
  const _ChatMessage._() : super._();

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  /// Identificador único da mensagem (UUID).
  @override
  String get id;

  /// Identificador da aventura à qual esta mensagem pertence (Chave Estrangeira).
  @override
  String get adventureId;

  /// O remetente da mensagem.
  ///
  /// Valores comuns: 'player', 'ai', 'system'.
  @override
  String get sender;

  /// O conteúdo textual da mensagem.
  @override
  String get content;

  /// Timestamp da criação da mensagem.
  /// Armazenado como milissegundos desde a época (Unix epoch).
  @override
  int get timestamp;

  /// Status de sincronização da mensagem com um backend (se aplicável).
  ///
  /// Valores possíveis:
  /// - 0: Apenas local, não sincronizado.
  /// - 1: Sincronizando.
  /// - 2: Sincronizado com sucesso.
  /// - -1: Erro durante a sincronização.
  @override
  int get syncStatus;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
