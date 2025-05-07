# Documentação Técnica - ImageUtils

**Classe:** `ImageUtils`
**Localização:** `ai_master/lib/utils/image_utils.dart`

## 1. Visão Geral

A classe `ImageUtils` serve como um local centralizado para funções utilitárias relacionadas ao processamento e manipulação de imagens dentro do aplicativo AI Master. O objetivo principal é encapsular lógicas comuns de tratamento de imagem, evitando duplicação de código e promovendo a reutilização.

Atualmente, a classe contém um método estático para decodificar strings Base64 que podem conter ruídos comuns, como prefixos de Data URL.

## 2. Métodos Estáticos

### 2.1. `decodeCleanBase64Image`

```dart
static Uint8List? decodeCleanBase64Image(String? rawBase64)
```

**Descrição:**

Este método é responsável por decodificar uma string Base64 que representa uma imagem, realizando uma limpeza prévia para lidar com formatos comuns encontrados na web ou em APIs.

**Parâmetros:**

| Parâmetro   | Tipo    | Obrigatório | Descrição                                                                 |
| :---------- | :------ | :---------- | :------------------------------------------------------------------------ |
| `rawBase64` | `String?` | Sim         | A string Base64 potencialmente "suja" (com prefixos, espaços, etc.) a ser decodificada. Pode ser nula. |

**Retorno:**

*   `Uint8List?`: Uma lista de bytes (`Uint8List`) representando a imagem decodificada, se a operação for bem-sucedida.
*   `null`: Se a string de entrada `rawBase64` for nula, vazia, ou se ocorrer qualquer erro durante o processo de limpeza ou decodificação.

**Lógica de Processamento:**

1.  **Verificação Inicial:** Verifica se `rawBase64` é `null` ou vazia. Se for, retorna `null` imediatamente.
2.  **Bloco `try-catch`:** Envolve toda a lógica de limpeza e decodificação para capturar exceções potenciais (ex: `FormatException` durante a decodificação).
3.  **Remoção de Prefixo Data URL:** Procura pelo caractere `,`. Se encontrado, assume que a string possui um prefixo Data URL (ex: `data:image/png;base64,`) e remove tudo até a vírgula (inclusive).
4.  **Remoção de Espaços/Quebras de Linha:** Remove todos os caracteres de espaço em branco (incluindo quebras de linha) da string usando `replaceAll` com uma expressão regular (`\s+`).
5.  **Decodificação:** Chama a função `base64Decode` do `dart:convert` na string limpa.
6.  **Tratamento de Erro:** Se qualquer exceção for capturada no bloco `catch`:
    *   Registra uma mensagem de erro detalhada usando `debugPrint`, incluindo a mensagem da exceção, uma prévia da string de entrada e o stack trace. `debugPrint` garante que o log só apareça em builds de depuração.
    *   Retorna `null`.

**Observação sobre Padding:** O código atualmente confia na capacidade do `base64Decode` do Dart de lidar com padding opcional. Uma versão anterior poderia incluir a adição explícita de padding (`=`), mas foi removida por enquanto pela robustez do decodificador padrão.

## 3. Histórico de Implementação

*   **[Data da Criação - Ex: 2025-05-04]:** Criação da classe `ImageUtils` e do método `decodeCleanBase64Image` para centralizar a lógica de decodificação de Base64 que estava duplicada nos widgets `OngoingAdventureCard` e `AvailableScenarioCard`.

*(Nota: Substitua "[Data da Criação]" pela data real.)*