-- 3. Implementar procedimentos armazenados (stored procedures) que garantam a validação
-- das regras semânticas criadas. Nesse caso, o mecanismo de permissões deve ser utilizado
-- para criar um usuário que somente tenha acesso à manipulação dos dados envolvidos
-- através do procedimento definido.

-- RS2 - inserção de invoice_line só pelo procedimento

CREATE OR REPLACE PROCEDURE sp_inserir_invoice_line(
    p_invoice_id INTEGER,
    p_track_id INTEGER,
    p_quantity INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER          -- roda com os privilégios do dono do procedimento
SET search_path = public
AS $$
DECLARE
    v_preco NUMERIC(10,2);
    v_novo_id INTEGER;
BEGIN
    -- a fatura precisa existir
    IF NOT EXISTS (SELECT 1 FROM invoice WHERE invoice_id = p_invoice_id) THEN
        RAISE EXCEPTION 'Fatura % não existe', p_invoice_id;
    END IF;

    -- a faixa precisa existir, e já aproveitamos pra pegar o preço dela
    SELECT unit_price INTO v_preco FROM track WHERE track_id = p_track_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Faixa % não existe', p_track_id;
    END IF;

    -- quantidade tem que ser positiva
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantidade deve ser maior que zero (recebido: %)', p_quantity;
    END IF;

    -- o invoice_line_id não é serial no Chinook, então geramos o próximo na mão
    SELECT COALESCE(MAX(invoice_line_id), 0) + 1 INTO v_novo_id FROM invoice_line;

    INSERT INTO invoice_line (invoice_line_id, invoice_id, track_id, unit_price, quantity)
    VALUES (v_novo_id, p_invoice_id, p_track_id, v_preco, p_quantity);
END;
$$;

-- Permissões: o usuário da aplicação só mexe em invoice_line pelo procedimento

-- cria o papel só se ainda não existir (role é a nível de cluster)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_vendas') THEN
        CREATE ROLE app_vendas LOGIN PASSWORD 'senha123';
    END IF;
END $$;

-- nada de escrita direta na tabela, só leitura e execução do procedimento
GRANT USAGE ON SCHEMA public TO app_vendas;
GRANT SELECT ON invoice_line TO app_vendas;
GRANT EXECUTE ON PROCEDURE sp_inserir_invoice_line(INTEGER, INTEGER, INTEGER) TO app_vendas;

-- Exemplos de uso:
-- SET ROLE app_vendas;
-- INSERT INTO invoice_line (invoice_line_id, invoice_id, track_id, unit_price, quantity)
--   VALUES (999999, 1, 1, 0.99, 1);          -- erro: permission denied for table invoice_line
-- CALL sp_inserir_invoice_line(1, 1, 2);     -- ok, insere pelo procedimento
-- CALL sp_inserir_invoice_line(1, 1, 0);     -- erro: quantidade deve ser maior que zero
-- RESET ROLE;
