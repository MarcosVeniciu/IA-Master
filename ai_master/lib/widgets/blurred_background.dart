import 'dart:typed_data';
import 'dart:ui'; // Para ImageFilter

import 'package:flutter/material.dart';

/// Um widget reutilizável que exibe uma imagem de fundo (opcional),
/// um widget de overlay personalizável sobre a imagem,
/// e um widget filho sobreposto a tudo.
///
/// Ideal para criar cards ou seções com fundos visuais e overlays.
/// O efeito de blur foi removido para otimização de performance.
class ImageWithOverlayWidget extends StatelessWidget {
  /// Os bytes da imagem a ser exibida no fundo. Se nulo, um [placeholder] será exibido.
  final Uint8List? imageBytes;

  // sigmaX e sigmaY removidos

  /// O widget a ser usado como camada de overlay sobre a imagem.
  /// Pode ser um [Container] com cor sólida/gradiente ou qualquer outro widget.
  final Widget overlayWidget;

  /// O widget filho principal a ser exibido sobre todas as camadas de fundo (imagem, overlay).
  final Widget child;

  /// O [BoxFit] a ser usado para ajustar a imagem de fundo. O padrão é [BoxFit.cover].
  final BoxFit imageFit;

  /// Um widget opcional a ser exibido como placeholder se [imageBytes] for nulo.
  /// Se não fornecido, um [Container] cinza escuro padrão com um ícone será usado.
  final Widget? placeholder;

  /// Cria uma instância de [ImageWithOverlayWidget].
  ///
  /// Requer [overlayWidget] e [child].
  /// [imageBytes] fornece a imagem de fundo; se for nulo, [placeholder] (ou um padrão) é usado.
  const ImageWithOverlayWidget({
    super.key,
    this.imageBytes,
    // sigmaX e sigmaY removidos do construtor
    required this.overlayWidget,
    required this.child,
    this.imageFit = BoxFit.cover,
    this.placeholder,
  });

  /// Constrói o placeholder padrão se nenhum for fornecido.
  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // --- Camada 1: Imagem de Fundo ou Placeholder ---
        if (imageBytes != null)
          Image.memory(
            imageBytes!,
            fit: imageFit,
            // Exibe placeholder em caso de erro ao renderizar a imagem
            errorBuilder:
                (context, error, stackTrace) =>
                    placeholder ?? _buildDefaultPlaceholder(),
          )
        else
          placeholder ?? _buildDefaultPlaceholder(),

        // --- Camada 2: Overlay ---
        // O BackdropFilter foi removido. O overlayWidget é aplicado diretamente.
        overlayWidget,

        // --- Camada 3: Conteúdo Principal ---
        child,
      ],
    );
  }
}
