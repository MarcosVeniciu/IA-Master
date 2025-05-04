# ChatMessage Schema

## Fields
- id: TEXT (PRIMARY KEY NOT NULL, Identificador único da mensagem, pode ser um UUID)
- adventure_id: TEXT (NOT NULL, Chave estrangeira referenciando Adventure.id)
- sender: TEXT (NOT NULL, Indica quem enviou a mensagem, ex: 'player', 'ai', 'system')
- content: TEXT (NOT NULL, O conteúdo textual da mensagem)
- timestamp: INTEGER (NOT NULL, Timestamp Unix da criação da mensagem, para ordenação)
- sync_status: INTEGER (NOT NULL DEFAULT 0, Otimização: 0=local, 1=sincronizado, 2=modificado localmente)

## Relationships
- **N:1:** Muitas `ChatMessage`s pertencem a uma `Adventure`. A ligação é feita via `adventure_id` referenciando `Adventure.id`.

## Mobile Optimizations
- **Índice:** Criar um índice composto em (`adventure_id`, `timestamp`) para buscar e ordenar eficientemente as mensagens de uma aventura específica.
- **Sincronização:** O campo `sync_status` facilita a implementação de estratégias de sincronização (delta sync) se o backup/sincronização online for adicionado futuramente.
- **Chave Primária:** Usar um UUID (armazenado como TEXT) para `id` garante unicidade.
- **Foreign Key Constraint:** Definir uma restrição de chave estrangeira em `adventure_id` para garantir a integridade referencial com a tabela `Adventure`.