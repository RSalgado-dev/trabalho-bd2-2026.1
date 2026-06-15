Testes do procedimento `sp_inserir_invoice_line` e das permissões (RS2).

Rodando como o usuário `app_vendas` (`SET ROLE app_vendas;`):

1) INSERT direto na tabela (o usuário não tem permissão de escrita):
```sql
INSERT INTO invoice_line (invoice_line_id, invoice_id, track_id, unit_price, quantity)
VALUES (999999, 1, 1, 0.99, 1);
```
```
ERROR:  permission denied for table invoice_line
```

2) Inserindo pelo procedimento (o preço vem da própria faixa):
```sql
CALL sp_inserir_invoice_line(1, 1, 2);
```
| | invoice_line_id | invoice_id | track_id | unit_price | quantity |
|---|---|---|---|---|---|
| 1 | 2241 | 1 | 1 | 0.99 | 2 |

3) Procedimento com quantidade zero:
```sql
CALL sp_inserir_invoice_line(1, 1, 0);
```
```
ERROR:  Quantidade deve ser maior que zero (recebido: 0)
CONTEXT:  PL/pgSQL function sp_inserir_invoice_line(integer,integer,integer) line 19 at RAISE
```

4) Procedimento com uma faixa que não existe:
```sql
CALL sp_inserir_invoice_line(1, 999999, 1);
```
```
ERROR:  Faixa 999999 não existe
CONTEXT:  PL/pgSQL function sp_inserir_invoice_line(integer,integer,integer) line 14 at RAISE
```
