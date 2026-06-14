--5. Implemente uma solução através da programação em banco de dados para validar os valores de uma coluna 
--que represente uma situação (estado) garantindo que os seus valores e suas transições atendam a especificação 
--de um diagrama de transição de estados (DTE). Quanto mais genérica e reutilizável for a solução melhor a pontuação 
--nessa questão. Junto da solução deverá ser entregue um cenário de teste demonstrando o funcionamento da solução.


-- DTE para armazenamento de estados e transições

CREATE TABLE dte (
    codigo VARCHAR(50) PRIMARY KEY,
    descricao TEXT NOT NULL
);

CREATE TABLE dte_estado (
    codigo_dte VARCHAR(50) NOT NULL,
    estado VARCHAR(30) NOT NULL,
    inicial BOOLEAN NOT NULL DEFAULT FALSE,

    PRIMARY KEY (codigo_dte, estado),

    FOREIGN KEY (codigo_dte)
        REFERENCES dte(codigo)
);

CREATE TABLE dte_transicao (
    codigo_dte VARCHAR(50) NOT NULL,
    estado_origem VARCHAR(30) NOT NULL,
    estado_destino VARCHAR(30) NOT NULL,

    PRIMARY KEY (codigo_dte, estado_origem, estado_destino),

    FOREIGN KEY (codigo_dte, estado_origem)
        REFERENCES dte_estado(codigo_dte, estado),

    FOREIGN KEY (codigo_dte, estado_destino)
        REFERENCES dte_estado(codigo_dte, estado)
);

--Validação

CREATE OR REPLACE FUNCTION fn_validar_dte()
RETURNS TRIGGER
LANGUAGE plpgsql 
AS $$
DECLARE
    v_codigo_dte VARCHAR(50);
    v_coluna_estado TEXT;

    v_estado_antigo TEXT;
    v_estado_novo TEXT;

    v_existe INTEGER;
BEGIN
    v_codigo_dte := TG_ARGV[0];
    v_coluna_estado := TG_ARGV[1];

    v_estado_novo := to_jsonb(NEW) ->> v_coluna_estado;

    SELECT COUNT(*) INTO v_existe FROM dte_estado
    WHERE codigo_dte = v_codigo_dte AND estado = v_estado_novo;

    if v_existe = 0 THEN
        RAISE EXCEPTION 'Estado % não é válido para o DTE %', v_estado_novo, v_codigo_dte;
    END IF;

    -- CASO INSERT
    IF TG_OP = 'INSERT' THEN
        SELECT COUNT(*)
        INTO v_existe
        FROM dte_estado
        WHERE codigo_dte = v_codigo_dte
            AND estado = v_estado_novo
            AND inicial = TRUE;

        IF v_existe = 0 THEN
            RAISE EXCEPTION
                '% não é um estado inicial válido para o DTE %',
                v_estado_novo,
                v_codigo_dte;
        END IF;
    -- CASO UPDATE
    ELSIF TG_OP = 'UPDATE' THEN
            v_estado_antigo := to_jsonb(OLD) ->> v_coluna_estado;

        IF v_estado_antigo <> v_estado_novo THEN
            SELECT COUNT(*)
            INTO v_existe
            FROM dte_transicao
            WHERE codigo_dte = v_codigo_dte
              AND estado_origem = v_estado_antigo
              AND estado_destino = v_estado_novo;

            IF v_existe = 0 THEN
                RAISE EXCEPTION
                    '% -> % não é uma transição válida para o DTE %',
                    v_estado_antigo,
                    v_estado_novo,
                    v_codigo_dte
                    ;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;