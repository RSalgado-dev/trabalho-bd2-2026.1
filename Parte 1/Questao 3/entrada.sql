--3. Consultar as tabelas de catálogo para listar todas as chaves estrangeiras existentes informando as tabelas e colunas envolvidas.

SELECT
    tc.constraint_name AS "Nome da FK",
    tc.table_name AS "Tabela Origem (Filha)",
    kcu.column_name AS "Coluna Origem (FK)",
    ccu.table_name AS "Tabela Destino (Pai)",
    ccu.column_name AS "Coluna Destino (PK)"
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE 
    tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_schema = 'public'
ORDER BY 
    tc.table_name, 
    tc.constraint_name;
