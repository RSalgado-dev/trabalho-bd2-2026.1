# Parte 1 - Questão 5

## Cenário de teste

Para demonstrar o funcionamento da solução, foi criada uma tabela de solicitação de compra com a coluna `situacao`.

```sql
CREATE TABLE solicitacao_compra (
    id SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    situacao VARCHAR(30) NOT NULL DEFAULT 'RASCUNHO'
);
```

### DTE configurado

```sql
INSERT INTO dte (codigo, descricao)
VALUES (
    'SOLICITACAO_COMPRA',
    'Fluxo de estados de uma solicitação de compra'
);

INSERT INTO dte_estado (codigo_dte, estado, inicial)
VALUES
    ('SOLICITACAO_COMPRA', 'RASCUNHO',   TRUE),
    ('SOLICITACAO_COMPRA', 'ENVIADA',    FALSE),
    ('SOLICITACAO_COMPRA', 'APROVADA',   FALSE),
    ('SOLICITACAO_COMPRA', 'REJEITADA',  FALSE),
    ('SOLICITACAO_COMPRA', 'CANCELADA',  FALSE),
    ('SOLICITACAO_COMPRA', 'FINALIZADA', FALSE);

INSERT INTO dte_transicao (codigo_dte, estado_origem, estado_destino)
VALUES
    ('SOLICITACAO_COMPRA', 'RASCUNHO', 'ENVIADA'),
    ('SOLICITACAO_COMPRA', 'RASCUNHO', 'CANCELADA'),
    ('SOLICITACAO_COMPRA', 'ENVIADA',  'APROVADA'),
    ('SOLICITACAO_COMPRA', 'ENVIADA',  'REJEITADA'),
    ('SOLICITACAO_COMPRA', 'APROVADA', 'FINALIZADA');
```

Representação das transições válidas:

```text
RASCUNHO
├── ENVIADA
│   ├── APROVADA
│   │   └── FINALIZADA
│   └── REJEITADA
└── CANCELADA
```

### Trigger aplicado

```sql
CREATE TRIGGER trg_validar_dte_solicitacao_compra
BEFORE INSERT OR UPDATE OF situacao
ON solicitacao_compra
FOR EACH ROW
EXECUTE FUNCTION fn_validar_dte('SOLICITACAO_COMPRA', 'situacao');
```

## Resultados dos testes

| Teste | Operação | Resultado |
|---|---|---|
| 1 | Inserir sem informar `situacao` | Válido: usa o estado inicial `RASCUNHO`. |
| 2 | Inserir com `situacao = 'ENVIADA'` | Inválido: `ENVIADA` não é estado inicial. |
| 3 | Inserir com `situacao = 'INVALIDO'` | Inválido: estado não cadastrado no DTE. |
| 4 | Atualizar `RASCUNHO -> ENVIADA` | Válido: transição cadastrada. |
| 5 | Atualizar `ENVIADA -> FINALIZADA` | Inválido: transição não cadastrada. |
| 6 | Atualizar `ENVIADA -> REJEITADA` | Válido: transição cadastrada. |
| 7 | Atualizar `REJEITADA -> RASCUNHO` | Inválido: transição não cadastrada. |

### Teste 1: inserção usando estado padrão

```sql
INSERT INTO solicitacao_compra (descricao, valor)
VALUES ('Compra de notebook', 3500.00);
```

Resultado:

| id | descricao | valor | situacao |
|---|---|---:|---|
| 1 | Compra de notebook | 3500.00 | RASCUNHO |

### Teste 2: inserção com estado não inicial

```sql
INSERT INTO solicitacao_compra (descricao, valor, situacao)
VALUES ('Compra de teclado', 200.00, 'ENVIADA');
```

Resultado:

```text
ERROR:  ENVIADA não é um estado inicial válido para o DTE SOLICITACAO_COMPRA
CONTEXT:  PL/pgSQL function fn_validar_dte() line 30 at RAISE
```

### Teste 3: inserção com estado inexistente

```sql
INSERT INTO solicitacao_compra (descricao, valor, situacao)
VALUES ('Compra de teclado', 200.00, 'INVALIDO');
```

Resultado:

```text
ERROR:  Estado INVALIDO não é válido para o DTE SOLICITACAO_COMPRA
CONTEXT:  PL/pgSQL function fn_validar_dte() line 20 at RAISE
```

### Teste 4: transição válida de `RASCUNHO` para `ENVIADA`

```sql
UPDATE solicitacao_compra
SET situacao = 'ENVIADA'
WHERE descricao = 'Compra de notebook';
```

Resultado:

| id | descricao | valor | situacao |
|---|---|---:|---|
| 1 | Compra de notebook | 3500.00 | ENVIADA |

### Teste 5: transição inválida de `ENVIADA` para `FINALIZADA`

```sql
UPDATE solicitacao_compra
SET situacao = 'FINALIZADA'
WHERE descricao = 'Compra de notebook';
```

Resultado:

```text
ERROR:  ENVIADA -> FINALIZADA não é uma transição válida para o DTE SOLICITACAO_COMPRA
CONTEXT:  PL/pgSQL function fn_validar_dte() line 51 at RAISE
```

### Teste 6: transição válida de `ENVIADA` para `REJEITADA`

```sql
UPDATE solicitacao_compra
SET situacao = 'REJEITADA'
WHERE descricao = 'Compra de notebook';
```

Resultado:

| id | descricao | valor | situacao |
|---|---|---:|---|
| 1 | Compra de notebook | 3500.00 | REJEITADA |

### Teste 7: transição inválida de `REJEITADA` para `RASCUNHO`

```sql
UPDATE solicitacao_compra
SET situacao = 'RASCUNHO'
WHERE descricao = 'Compra de notebook';
```

Resultado:

```text
ERROR:  REJEITADA -> RASCUNHO não é uma transição válida para o DTE SOLICITACAO_COMPRA
CONTEXT:  PL/pgSQL function fn_validar_dte() line 51 at RAISE
```
