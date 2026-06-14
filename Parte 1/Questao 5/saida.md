## Criação e validação do trigger e function

### Montagem do ambiente

```sql
-- Cenário exemplo ( Solicitação de Compra )
CREATE TABLE solicitacao_compra (
    id SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    situacao VARCHAR(30) NOT NULL DEFAULT 'RASCUNHO'
);
```

```sql
-- Insere a tabela no dte
INSERT INTO dte (codigo, descricao)
VALUES (
    'SOLICITACAO_COMPRA',
    'Fluxo de estados de uma solicitação de compra'
);

-- insere os estados possiveis da tabela
INSERT INTO dte_estado (codigo_dte, estado, inicial, final)
VALUES
    ('SOLICITACAO_COMPRA', 'RASCUNHO',   TRUE,  FALSE),
    ('SOLICITACAO_COMPRA', 'ENVIADA',    FALSE, FALSE),
    ('SOLICITACAO_COMPRA', 'APROVADA',   FALSE, FALSE),
    ('SOLICITACAO_COMPRA', 'REJEITADA',  FALSE, TRUE),
    ('SOLICITACAO_COMPRA', 'CANCELADA',  FALSE, TRUE),
    ('SOLICITACAO_COMPRA', 'FINALIZADA', FALSE, TRUE);

-- insere as transações validas da tabela
INSERT INTO dte_transicao (codigo_dte, estado_origem, estado_destino)
VALUES
    ('SOLICITACAO_COMPRA', 'RASCUNHO',  'ENVIADA'),
    ('SOLICITACAO_COMPRA', 'RASCUNHO',  'CANCELADA'),
    ('SOLICITACAO_COMPRA', 'ENVIADA',   'APROVADA'),
    ('SOLICITACAO_COMPRA', 'ENVIADA',   'REJEITADA'),
    ('SOLICITACAO_COMPRA', 'APROVADA',  'FINALIZADA');
```

```sql
-- Criação do Trigger Para o Exemplo
CREATE TRIGGER trg_validar_dte_solicitacao_compra
BEFORE INSERT OR UPDATE OF situacao
ON solicitacao_compra
FOR EACH ROW
EXECUTE FUNCTION fn_validar_dte('SOLICITACAO_COMPRA', 'situacao');
```

### Testes

Transições validas
```
RASCUNHO
   ├──> ENVIADA
   │       ├──> APROVADA
   │       │       └──> FINALIZADA
   │       └──> REJEITADA
   └──> CANCELADA
```

- Caso Valido: Inserção sem informar situação (Usando o default)
```sql
INSERT INTO solicitacao_compra (descricao, valor)
VALUES ('Compra de notebook', 3500.00);
```
| id | descricao | valor | situacao |
|---|---|---|---|
| 1 | Compra de notebook | 3500.00 | RASCUNHO |


- Caso Invalido: Inserção informando situação que não é estado inicial

```sql
INSERT INTO solicitacao_compra (descricao, valor, situacao)
VALUES ('Compra de teclado', 200.00, 'ENVIADA');
```

ERROR:  ENVIADA não é um estado inicial válido para o DTE SOLICITACAO_COMPRA
CONTEXT:  PL/pgSQL function fn_validar_dte() line 30 at RAISE

- Caso Invalido: Inserção com estado invalido
```sql
INSERT INTO solicitacao_compra (descricao, valor, situacao)
VALUES ('Compra de teclado', 200.00, 'INVALIDO');
```

ERROR:  Estado INVALIDO não é válido para o DTE SOLICITACAO_COMPRA
CONTEXT:  PL/pgSQL function fn_validar_dte() line 20 at RAISE

- Caso Valido: Update de situação: Rascunho -> Enviada
```sql
UPDATE solicitacao_compra
SET situacao = 'ENVIADA'
WHERE descricao = 'Compra de notebook';
```
| id | descricao | valor | situacao |
|---|---|---|---|
| 1 | Compra de notebook | 3500.00 | ENVIADA |

- Caso Invalido: Update de situação: Enviada -> Finalizada
```sql
UPDATE solicitacao_compra
SET situacao = 'FINALIZADA'
WHERE descricao = 'Compra de notebook';
```

ERROR:  ENVIADA -> FINALIZADA não é uma transição válida para o DTE SOLICITACAO_COMPRA
CONTEXT:  PL/pgSQL function fn_validar_dte() line 51 at RAISE

- Caso Valido: Update de situação: Enviada -> Rejeitada
```sql
UPDATE solicitacao_compra
SET situacao = 'REJEITADA'
WHERE descricao = 'Compra de notebook';
```
| id | descricao | valor | situacao |
|---|---|---|---|
| 1 | Compra de notebook | 3500.00 | REJEITADA |

- Caso Invalido: Update de situação: Rejeitada -> Rascunho
```sql
UPDATE solicitacao_compra
SET situacao = 'RASCUNHO'
WHERE descricao = 'Compra de notebook';
```

ERROR:  REJEITADA -> RASCUNHO não é uma transição válida para o DTE SOLICITACAO_COMPRA
CONTEXT:  PL/pgSQL function fn_validar_dte() line 51 at RAISE