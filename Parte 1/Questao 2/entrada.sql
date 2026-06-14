-- 2. Criar usando a linguagem de programação do SGBD escolhido um procedimento que remova todos os índices de uma tabela informada como parâmetro.

CREATE OR REPLACE PROCEDURE sp_remover_indices_tabela(p_table_name VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE
    v_index_name VARCHAR;
BEGIN
    FOR v_index_name IN 
        SELECT i.relname
        FROM pg_class t
        JOIN pg_index ix ON t.oid = ix.indrelid
        JOIN pg_class i ON i.oid = ix.indexrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = 'public' 
          AND t.relname = p_table_name
          AND ix.indisprimary = FALSE
    LOOP
        EXECUTE 'DROP INDEX IF EXISTS ' || quote_ident(v_index_name);
    END LOOP;
END;
$$;

-- Exemplos de uso: 
CALL sp_remover_indices_tabela('album');
CALL sp_remover_indices_tabela('employee');
