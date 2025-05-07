# Documentação Técnica - OngoingAdventureCard

**Widget:** `OngoingAdventureCard`
**Localização:** `ai_master/lib/features/main_screen/widgets/ongoing_adventure_card.dart`

## 1. Visão Geral

O `OngoingAdventureCard` é um widget `StatelessWidget` projetado para exibir um resumo visual de uma aventura de RPG que está atualmente em andamento. Ele é tipicamente utilizado em listas horizontais na tela principal, oferecendo ao usuário um acesso rápido para continuar suas aventuras.

O card apresenta:
*   Uma imagem de fundo representativa do cenário da aventura.
*   Um overlay gradiente escuro para garantir a legibilidade do texto sobre a imagem.
*   O título da aventura e o título do cenário.
*   Uma barra de progresso indicando a porcentagem concluída da aventura.
*   A data do último acesso formatada de forma relativa (ex: "há 5 minutos", "há 2 dias").
*   Um botão de "play" para acionar a continuação da aventura.

## 2. Parâmetros

| Parâmetro             | Tipo          | Obrigatório | Descrição                                                                 |
| :-------------------- | :------------ | :---------- | :------------------------------------------------------------------------ |
| `key`                 | `Key?`        | Não         | Chave padrão do widget Flutter.                                           |
| `adventure`           | `Adventure`   | Sim         | O objeto `Adventure` contendo os dados da aventura a ser exibida.         |
| `onTap`               | `VoidCallback`| Sim         | Função a ser chamada quando o card ou o botão de play é tocado.           |
| `scenarioImageBase64` | `String?`     | Não         | String Base64 opcional contendo a imagem de fundo do cenário associado. |

## 3. Lógica Principal

1.  **Dimensões:** A largura do card é calculada como uma porcentagem da largura da tela (`MediaQuery.of(context).size.width * 0.42`). A proporção é fixada em 16:9 (`AspectRatio`).
2.  **Progresso:** O valor do progresso (`progressValue`) é obtido de `adventure.progressIndicator`, garantindo que esteja entre 0.0 e 1.0 (ou 0.0 se nulo).
3.  **Data:** A data do último acesso (`adventure.lastPlayedDate`) é formatada usando o pacote `timeago` para exibição relativa em português ("pt\_BR").
4.  **Estrutura Visual (Stack):** O card utiliza um `Stack` para sobrepor elementos:
    *   **Camada 1 (Fundo):** A imagem de fundo (`_buildBackgroundImage`).
    *   **Camada 2 (Overlay):** Um `Container` com `LinearGradient` escuro para contraste.
    *   **Camada 3 (Conteúdo):** Um `Column` com `Padding` contendo:
        *   Título da Aventura (`adventure.adventureTitle`).
        *   Título do Cenário (`adventure.scenarioTitle`).
        *   `Spacer` para empurrar o conteúdo inferior para baixo.
        *   Barra de Progresso (`_buildProgressBar`).
        *   Data formatada.
    *   **Camada 4 (Botão Play):** Um `CircleAvatar` com `IconButton` posicionado no canto inferior direito.
5.  **Interatividade:** Um `InkWell` envolve o conteúdo do `Card`, permitindo que o `onTap` seja acionado ao tocar em qualquer parte do card.

## 4. Tratamento da Imagem de Fundo (`_buildBackgroundImage`)

*   A função `_buildBackgroundImage` é responsável por decodificar e exibir a imagem do cenário.
*   **Utiliza `ImageUtils.decodeCleanBase64Image(scenarioImageBase64)` para decodificar a string Base64 fornecida.** Esta função centralizada lida com a limpeza de prefixos comuns (como `data:image/...;base64,`) antes da decodificação.
*   Se a decodificação for bem-sucedida e retornar `Uint8List` (bytes da imagem), um widget `Image.memory` é usado para exibir a imagem com `BoxFit.cover`. Inclui um `frameBuilder` para um efeito de fade-in suave e um `errorBuilder` para exibir um placeholder (`_buildPlaceholder`) caso `Image.memory` falhe.
*   Se `ImageUtils.decodeCleanBase64Image` retornar `null` (indicando que `scenarioImageBase64` era nulo, vazio ou inválido), um placeholder (`_buildPlaceholder` com `Icons.image_not_supported`) é exibido diretamente.

## 5. Barra de Progresso (`_buildProgressBar`)

*   A função `_buildProgressBar` cria a barra de progresso visual.
*   Utiliza um `Stack` para sobrepor:
    *   Um `Container` de fundo (track) com cor semi-transparente.
    *   Um `FractionallySizedBox` preenchido com a cor primária do tema, cuja largura é determinada pelo `progressValue`.
    *   Um `Text` centralizado exibindo a porcentagem formatada (ex: "75% concluído").

## 6. Histórico de Implementação

*   **2025-05-04:** Centralizada a barra de progresso horizontalmente no card.
*   **2025-05-04:** Ajustada a barra de progresso: texto alinhado à esquerda e cor da barra alterada para vermelho.
*   **2025-05-04:** Dobrada a largura do card (de 42% para 84% da largura da tela) para maior destaque.
*   **[Data da Refatoração - Ex: 2025-05-04]:** Refatorado para usar `ImageUtils.decodeCleanBase64Image` para decodificação da imagem Base64, removendo a lógica de decodificação local. O parâmetro `scenarioImageBase64` tornou-se opcional. Adicionado título do cenário como subtítulo. Melhorias visuais e de layout (padding, sombras, tamanhos de fonte, elevação).
*   **[Data da Criação Inicial]:** Versão inicial do widget.

*(Nota: Substitua "[Data da Refatoração]" e "[Data da Criação Inicial]" pelas datas reais, se conhecidas.)*