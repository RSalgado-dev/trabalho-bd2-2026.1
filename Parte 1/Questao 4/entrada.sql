--4. Criar usando a linguagem de programação do SGBD escolhido um script que construa de forma dinâmica a partir do 
--catálogo os comandos create table das tabelas existentes no esquema exemplo considerando pelo menos as informações 
--sobre colunas (nome, tipo e obrigatoriedade) e chaves primárias e estrangeiras.

CREATE
OR REPLACE FUNCTION fn_gerar_ddl_esquema (p_schema VARCHAR) RETURNS SETOF TEXT LANGUAGE plpgsql AS $$
DECLARE
    v_table_name VARCHAR;
    v_ddl TEXT;
    v_col_record RECORD;
    v_pk_cols TEXT;
    v_fk_record RECORD;
BEGIN
    FOR v_table_name IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = p_schema AND table_type = 'BASE TABLE'
    LOOP
        v_ddl := 'CREATE TABLE ' || p_schema || '.' || quote_ident(v_table_name) || ' (' || chr(10);
        
        FOR v_col_record IN 
            SELECT column_name, data_type, character_maximum_length, is_nullable
            FROM information_schema.columns
            WHERE table_schema = p_schema AND table_name = v_table_name
            ORDER BY ordinal_position
        LOOP
            v_ddl := v_ddl || '  ' || quote_ident(v_col_record.column_name) || ' ' || v_col_record.data_type;
            
            IF v_col_record.character_maximum_length IS NOT NULL THEN
                v_ddl := v_ddl || '(' || v_col_record.character_maximum_length || ')';
            END IF;
            
            IF v_col_record.is_nullable = 'NO' THEN
                v_ddl := v_ddl || ' NOT NULL';
            ELSE
                v_ddl := v_ddl || ' NULL';
            END IF;
            
            v_ddl := v_ddl || ',' || chr(10);
        END LOOP;

        SELECT string_agg(quote_ident(kcu.column_name), ', ') INTO v_pk_cols
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu 
          ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
        WHERE tc.table_schema = p_schema 
          AND tc.table_name = v_table_name 
          AND tc.constraint_type = 'PRIMARY KEY';

        IF v_pk_cols IS NOT NULL THEN
            v_ddl := v_ddl || '  CONSTRAINT pk_' || v_table_name || ' PRIMARY KEY (' || v_pk_cols || '),' || chr(10);
        END IF;

        FOR v_fk_record IN 
            SELECT 
                tc.constraint_name,
                string_agg(quote_ident(kcu.column_name), ', ') AS fk_cols,
                ccu.table_name AS ref_table,
                string_agg(quote_ident(ccu.column_name), ', ') AS ref_cols
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
            WHERE tc.table_schema = p_schema 
              AND tc.table_name = v_table_name 
              AND tc.constraint_type = 'FOREIGN KEY'
            GROUP BY tc.constraint_name, ccu.table_name
        LOOP
            v_ddl := v_ddl || '  CONSTRAINT ' || quote_ident(v_fk_record.constraint_name) || 
                     ' FOREIGN KEY (' || v_fk_record.fk_cols || ') REFERENCES ' || quote_ident(v_fk_record.ref_table) || 
                     ' (' || v_fk_record.ref_cols || '),' || chr(10);
        END LOOP;
        v_ddl := rtrim(v_ddl, ',' || chr(10)) || chr(10) || ');';
        
        RETURN NEXT v_ddl;
    END LOOP;
END;
$$;
