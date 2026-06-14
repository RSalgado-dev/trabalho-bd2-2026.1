--1. Consultar as tabelas de catálogo para listar todos os índices existentes acompanhados das tabelas e colunas indexadas pelo mesmo.

SELECT
  t.relname AS "Tabela",
  i.relname AS "Nome do Índice",
  a.attname AS "Coluna Indexada"
FROM
  pg_class t
  JOIN pg_index ix ON t.oid = ix.indrelid
  JOIN pg_class i ON i.oid = ix.indexrelid
  JOIN pg_attribute a ON a.attrelid = t.oid
  AND a.attnum = ANY (ix.indkey)
  JOIN pg_namespace n ON n.oid = t.relnamespace
WHERE
  n.nspname = 'public'
ORDER BY
  t.relname,
  i.relname;


