Exemplo:
invoice_id = 1 (dois registros em invoice_lines, cuja soma resultava em 1.98, primeira imagem mostra total e segunda imagem total de registros na tabela invoice_lines associados ao invoice de id 1)

| | invoice_id | total |
|---|---|---|
| 1 | 1 | 1.98|

| | count |
| 1 | 2 |

Depois de inserir um novo invoice_line com quantity(1) * unity_price(10) = 10.00
| | invoice_id | total |
|---|---|---|
| 1 | 1 | 11.98|

| | count |
| 1 | 3 |