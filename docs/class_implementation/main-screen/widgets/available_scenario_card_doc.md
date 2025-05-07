# Documentação Técnica - AvailableScenarioCard

**Widget:** `AvailableScenarioCard`
**Localização:** `ai_master/lib/features/main_screen/widgets/available_scenario_card.dart`

## 1. Visão Geral

O `AvailableScenarioCard` é um widget `StatelessWidget` usado para exibir informações resumidas sobre um cenário de RPG disponível para ser iniciado pelo usuário. Ele é geralmente apresentado em listas verticais, como na seção "Cenários Disponíveis" da tela principal.

O card apresenta:
*   Uma imagem miniatura representativa do cenário (se disponível).
*   O título do cenário.
*   A ambientação ou descrição breve do cenário.
*   Um botão "Start" para iniciar uma nova aventura baseada naquele cenário.

## 2. Parâmetros

| Parâmetro | Tipo          | Obrigatório | Descrição                                                                 |
| :-------- | :------------ | :---------- | :------------------------------------------------------------------------ |
| `key`     | `Key?`        | Não         | Chave padrão do widget Flutter.                                           |
| `scenario`| `Scenario`    | Sim         | O objeto `Scenario` contendo os dados do cenário a ser exibido.           |
| `onStart` | `VoidCallback`| Sim         | Função a ser chamada quando o card ou o botão "Start" é tocado.           |

## 3. Lógica Principal

1.  **Decodificação da Imagem:** Logo no início do método `build`, a imagem Base64 do cenário (`scenario.imageBase64`) é decodificada usando a função utilitária `ImageUtils.decodeCleanBase64Image`. O resultado (`Uint8List? imageBytes`) é armazenado para uso posterior.
2.  **Estrutura Visual (Row):** O card utiliza um `Card` com `InkWell` (para tornar todo o card clicável) e um `Padding` interno. O conteúdo principal é organizado em uma `Row`:
    *   **Coluna 1 (Imagem):** Um `ClipRRect` com `SizedBox` de tamanho fixo (80x80) exibe a imagem (`Image.memory`) se `imageBytes` não for nulo, ou um `Container` com ícone de placeholder (`Icons.image_not_supported`) caso contrário. Um `errorBuilder` no `Image.memory` também exibe um placeholder (`Icons.broken_image`) se houver erro ao renderizar os bytes.
    *   **Coluna 2 (Informações e Botão):** Um `Expanded` contém uma `Column` alinhada à esquerda:
        *   Título do Cenário (`scenario.title`).
        *   Ambientação (`scenario.ambiance`).
        *   `SizedBox` para espaçamento.
        *   Um `ElevatedButton.icon` ("Start") alinhado à direita, que chama `onStart` ao ser pressionado.

## 4. Tratamento da Imagem

*   A responsabilidade de decodificar a imagem Base64 (`scenario.imageBase64`) foi **centralizada na função `ImageUtils.decodeCleanBase64Image`**.
*   Esta função é chamada no início do `build` para obter os `Uint8List? imageBytes`.
*   A função `ImageUtils` lida internamente com strings Base64 nulas, vazias, ou que contenham prefixos (`data:image/...;base64,`), retornando `null` nesses casos ou se a decodificação falhar.
*   O widget então verifica se `imageBytes` é nulo para decidir se exibe a `Image.memory` ou o placeholder.

## 5. Histórico de Implementação

*   **[Data da Refatoração - Ex: 2025-05-04]:** Refatorado para usar `ImageUtils.decodeCleanBase64Image` para decodificação da imagem Base64, removendo a função `_decodeImage` local.
*   **[Data da Criação Inicial]:** Versão inicial do widget.

*(Nota: Substitua "[Data da Refatoração]" e "[Data da Criação Inicial]" pelas datas reais, se conhecidas.)*