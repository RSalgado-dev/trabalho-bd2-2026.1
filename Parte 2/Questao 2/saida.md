Testes da trigger `trg_validar_hierarquia` (RS1).

Hierarquia no começo: 1 (sem chefe), 2 -> 1, 3 -> 2, 4 -> 2, 5 -> 2, 6 -> 1, 7 -> 6, 8 -> 6.

1) Funcionário tentando reportar pra si mesmo:
```sql
UPDATE employee SET reports_to = employee_id WHERE employee_id = 2;
```
```
ERROR:  Funcionário 2 não pode reportar a si mesmo
CONTEXT:  PL/pgSQL function fn_validar_hierarquia() line 12 at RAISE
```

2) Criando um ciclo 1 -> 2 -> 1:
```sql
UPDATE employee SET reports_to = 2 WHERE employee_id = 1;
```
```
ERROR:  reports_to 2 para o funcionário 1 cria um ciclo na hierarquia
CONTEXT:  PL/pgSQL function fn_validar_hierarquia() line 19 at RAISE
```

3) Troca de chefe que é válida (o 3 passa a reportar pro 6):
```sql
UPDATE employee SET reports_to = 6 WHERE employee_id = 3;
```
| | employee_id | reports_to |
|---|---|---|
| 1 | 3 | 6 |
