// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adventure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Adventure _$AdventureFromJson(Map<String, dynamic> json) {
  return _Adventure.fromJson(json);
}

/// @nodoc
mixin _$Adventure {
  /// Identificador único da aventura (UUID).
  String get id => throw _privateConstructorUsedError;

  /// Título do cenário base da aventura.
  String get scenarioTitle =>
      throw _privateConstructorUsedError; // @JsonKey removida do parâmetro
  /// o progresso atual na aventura, um valor numerico entre 0.0 e 1.0 representando a porcentagem de progresso ( quantidade de cenas concluidas em relaçao ao total de cenas da aventura)
  double? get progressIndicator =>
      throw _privateConstructorUsedError; // @JsonKey removida do parâmetro
  /// Estado completo do jogo serializado como uma string JSON.
  /// Inclui variáveis, status de personagens, inventário, etc.
  String get gameState =>
      throw _privateConstructorUsedError; // @JsonKey removida do parâmetro
  /// Timestamp da última vez que a aventura foi jogada ou modificada.
  /// Armazenado como milissegundos desde a época (Unix epoch).
  int get lastPlayedDate =>
      throw _privateConstructorUsedError; // @JsonKey removida do parâmetro
  /// Status de sincronização da aventura com um backend (se aplicável).
  ///
  /// Valores possíveis:
  /// - 0: Apenas local, não sincronizado.
  /// - 1: Sincronizando.
  /// - 2: Sincronizado com sucesso.
  /// - -1: Erro durante a sincronização.
  int get syncStatus =>
      throw _privateConstructorUsedError; // @JsonKey removida do parâmetro
  /// Lista de mensagens do chat associadas a esta aventura.
  /// Este campo é transiente e não é persistido diretamente na tabela Adventure.
  /// É carregado sob demanda pelo [AdventureRepository].
  // @JsonKey removida do parâmetro, já que está no getter gerado.
  List<ChatMessage> get messages => throw _privateConstructorUsedError;

  /// Serializes this Adventure to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Adventure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdventureCopyWith<Adventure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdventureCopyWith<$Res> {
  factory $AdventureCopyWith(Adventure value, $Res Function(Adventure) then) =
      _$AdventureCopyWithImpl<$Res, Adventure>;
  @useResult
  $Res call({
    String id,
    String scenarioTitle,
    double? progressIndicator,
    String gameState,
    int lastPlayedDate,
    int syncStatus,
    List<ChatMessage> messages,
  });
}

/// @nodoc
class _$AdventureCopyWithImpl<$Res, $Val extends Adventure>
    implements $AdventureCopyWith<$Res> {
  _$AdventureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Adventure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scenarioTitle = null,
    Object? progressIndicator = freezed,
    Object? gameState = null,
    Object? lastPlayedDate = null,
    Object? syncStatus = null,
    Object? messages = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            scenarioTitle:
                null == scenarioTitle
                    ? _value.scenarioTitle
                    : scenarioTitle // ignore: cast_nullable_to_non_nullable
                        as String,
            progressIndicator:
                freezed == progressIndicator
                    ? _value.progressIndicator
                    : progressIndicator // ignore: cast_nullable_to_non_nullable
                        as double?,
            gameState:
                null == gameState
                    ? _value.gameState
                    : gameState // ignore: cast_nullable_to_non_nullable
                        as String,
            lastPlayedDate:
                null == lastPlayedDate
                    ? _value.lastPlayedDate
                    : lastPlayedDate // ignore: cast_nullable_to_non_nullable
                        as int,
            syncStatus:
                null == syncStatus
                    ? _value.syncStatus
                    : syncStatus // ignore: cast_nullable_to_non_nullable
                        as int,
            messages:
                null == messages
                    ? _value.messages
                    : messages // ignore: cast_nullable_to_non_nullable
                        as List<ChatMessage>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdventureImplCopyWith<$Res>
    implements $AdventureCopyWith<$Res> {
  factory _$$AdventureImplCopyWith(
    _$AdventureImpl value,
    $Res Function(_$AdventureImpl) then,
  ) = __$$AdventureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String scenarioTitle,
    double? progressIndicator,
    String gameState,
    int lastPlayedDate,
    int syncStatus,
    List<ChatMessage> messages,
  });
}

/// @nodoc
class __$$AdventureImplCopyWithImpl<$Res>
    extends _$AdventureCopyWithImpl<$Res, _$AdventureImpl>
    implements _$$AdventureImplCopyWith<$Res> {
  __$$AdventureImplCopyWithImpl(
    _$AdventureImpl _value,
    $Res Function(_$AdventureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Adventure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scenarioTitle = null,
    Object? progressIndicator = freezed,
    Object? gameState = null,
    Object? lastPlayedDate = null,
    Object? syncStatus = null,
    Object? messages = null,
  }) {
    return _then(
      _$AdventureImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        scenarioTitle:
            null == scenarioTitle
                ? _value.scenarioTitle
                : scenarioTitle // ignore: cast_nullable_to_non_nullable
                    as String,
        progressIndicator:
            freezed == progressIndicator
                ? _value.progressIndicator
                : progressIndicator // ignore: cast_nullable_to_non_nullable
                    as double?,
        gameState:
            null == gameState
                ? _value.gameState
                : gameState // ignore: cast_nullable_to_non_nullable
                    as String,
        lastPlayedDate:
            null == lastPlayedDate
                ? _value.lastPlayedDate
                : lastPlayedDate // ignore: cast_nullable_to_non_nullable
                    as int,
        syncStatus:
            null == syncStatus
                ? _value.syncStatus
                : syncStatus // ignore: cast_nullable_to_non_nullable
                    as int,
        messages:
            null == messages
                ? _value._messages
                : messages // ignore: cast_nullable_to_non_nullable
                    as List<ChatMessage>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdventureImpl extends _Adventure {
  const _$AdventureImpl({
    required this.id,
    required this.scenarioTitle,
    this.progressIndicator,
    required this.gameState,
    required this.lastPlayedDate,
    this.syncStatus = 0,
    final List<ChatMessage> messages = const [],
  }) : _messages = messages,
       super._();

  factory _$AdventureImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdventureImplFromJson(json);

  /// Identificador único da aventura (UUID).
  @override
  final String id;

  /// Título do cenário base da aventura.
  @override
  final String scenarioTitle;
  // @JsonKey removida do parâmetro
  /// o progresso atual na aventura, um valor numerico entre 0.0 e 1.0 representando a porcentagem de progresso ( quantidade de cenas concluidas em relaçao ao total de cenas da aventura)
  @override
  final double? progressIndicator;
  // @JsonKey removida do parâmetro
  /// Estado completo do jogo serializado como uma string JSON.
  /// Inclui variáveis, status de personagens, inventário, etc.
  @override
  final String gameState;
  // @JsonKey removida do parâmetro
  /// Timestamp da última vez que a aventura foi jogada ou modificada.
  /// Armazenado como milissegundos desde a época (Unix epoch).
  @override
  final int lastPlayedDate;
  // @JsonKey removida do parâmetro
  /// Status de sincronização da aventura com um backend (se aplicável).
  ///
  /// Valores possíveis:
  /// - 0: Apenas local, não sincronizado.
  /// - 1: Sincronizando.
  /// - 2: Sincronizado com sucesso.
  /// - -1: Erro durante a sincronização.
  @override
  @JsonKey()
  final int syncStatus;
  // @JsonKey removida do parâmetro
  /// Lista de mensagens do chat associadas a esta aventura.
  /// Este campo é transiente e não é persistido diretamente na tabela Adventure.
  /// É carregado sob demanda pelo [AdventureRepository].
  // @JsonKey removida do parâmetro, já que está no getter gerado.
  final List<ChatMessage> _messages;
  // @JsonKey removida do parâmetro
  /// Lista de mensagens do chat associadas a esta aventura.
  /// Este campo é transiente e não é persistido diretamente na tabela Adventure.
  /// É carregado sob demanda pelo [AdventureRepository].
  // @JsonKey removida do parâmetro, já que está no getter gerado.
  @override
  @JsonKey()
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  String toString() {
    return 'Adventure(id: $id, scenarioTitle: $scenarioTitle, progressIndicator: $progressIndicator, gameState: $gameState, lastPlayedDate: $lastPlayedDate, syncStatus: $syncStatus, messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdventureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scenarioTitle, scenarioTitle) ||
                other.scenarioTitle == scenarioTitle) &&
            (identical(other.progressIndicator, progressIndicator) ||
                other.progressIndicator == progressIndicator) &&
            (identical(other.gameState, gameState) ||
                other.gameState == gameState) &&
            (identical(other.lastPlayedDate, lastPlayedDate) ||
                other.lastPlayedDate == lastPlayedDate) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            const DeepCollectionEquality().equals(other._messages, _messages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    scenarioTitle,
    progressIndicator,
    gameState,
    lastPlayedDate,
    syncStatus,
    const DeepCollectionEquality().hash(_messages),
  );

  /// Create a copy of Adventure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdventureImplCopyWith<_$AdventureImpl> get copyWith =>
      __$$AdventureImplCopyWithImpl<_$AdventureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdventureImplToJson(this);
  }
}

abstract class _Adventure extends Adventure {
  const factory _Adventure({
    required final String id,
    required final String scenarioTitle,
    final double? progressIndicator,
    required final String gameState,
    required final int lastPlayedDate,
    final int syncStatus,
    final List<ChatMessage> messages,
  }) = _$AdventureImpl;
  const _Adventure._() : super._();

  factory _Adventure.fromJson(Map<String, dynamic> json) =
      _$AdventureImpl.fromJson;

  /// Identificador único da aventura (UUID).
  @override
  String get id;

  /// Título do cenário base da aventura.
  @override
  String get scenarioTitle; // @JsonKey removida do parâmetro
  /// o progresso atual na aventura, um valor numerico entre 0.0 e 1.0 representando a porcentagem de progresso ( quantidade de cenas concluidas em relaçao ao total de cenas da aventura)
  @override
  double? get progressIndicator; // @JsonKey removida do parâmetro
  /// Estado completo do jogo serializado como uma string JSON.
  /// Inclui variáveis, status de personagens, inventário, etc.
  @override
  String get gameState; // @JsonKey removida do parâmetro
  /// Timestamp da última vez que a aventura foi jogada ou modificada.
  /// Armazenado como milissegundos desde a época (Unix epoch).
  @override
  int get lastPlayedDate; // @JsonKey removida do parâmetro
  /// Status de sincronização da aventura com um backend (se aplicável).
  ///
  /// Valores possíveis:
  /// - 0: Apenas local, não sincronizado.
  /// - 1: Sincronizando.
  /// - 2: Sincronizado com sucesso.
  /// - -1: Erro durante a sincronização.
  @override
  int get syncStatus; // @JsonKey removida do parâmetro
  /// Lista de mensagens do chat associadas a esta aventura.
  /// Este campo é transiente e não é persistido diretamente na tabela Adventure.
  /// É carregado sob demanda pelo [AdventureRepository].
  // @JsonKey removida do parâmetro, já que está no getter gerado.
  @override
  List<ChatMessage> get messages;

  /// Create a copy of Adventure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdventureImplCopyWith<_$AdventureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
