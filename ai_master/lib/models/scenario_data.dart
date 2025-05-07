import 'dart:typed_data';

import 'package:ai_master/models/scenario.dart';

/// ## ScenarioData
///
/// Uma classe wrapper que encapsula um objeto [Scenario] e sua representação
/// de imagem decodificada como [Uint8List].
///
/// Esta classe é utilizada para otimizar a performance, permitindo que a
/// decodificação da imagem Base64 ocorra uma única vez (por exemplo, durante
/// a splash screen) e o resultado seja reutilizado pela UI.
class ScenarioData {
  /// O objeto [Scenario] original contendo todos os metadados do cenário.
  final Scenario scenario;

  /// Os bytes da imagem decodificada. Pode ser nulo se o cenário não tiver
  /// uma imagem associada ou se a decodificação falhar.
  final Uint8List? decodedImageBytes;

  /// Cria uma instância de [ScenarioData].
  ///
  /// Requer um [scenario] e, opcionalmente, os [decodedImageBytes].
  ScenarioData({required this.scenario, this.decodedImageBytes});
}
