-- 2. Implementar triggers que garantam a validação das regras semânticas criadas.

CREATE OR REPLACE FUNCTION fn_validar_hierarquia()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_atual INTEGER;
BEGIN
    IF NEW.reports_to IS NULL THEN
        RETURN NEW;
    END IF;

    IF NEW.reports_to = NEW.employee_id THEN
        RAISE EXCEPTION 'Funcionário % não pode reportar a si mesmo', NEW.employee_id;
    END IF;

    v_atual := NEW.reports_to;
    WHILE v_atual IS NOT NULL LOOP
        IF v_atual = NEW.employee_id THEN
            RAISE EXCEPTION 'reports_to % para o funcionário % cria um ciclo na hierarquia',
                NEW.reports_to, NEW.employee_id;
        END IF;
        SELECT reports_to INTO v_atual FROM employee WHERE employee_id = v_atual;
    END LOOP;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_hierarquia
BEFORE INSERT OR UPDATE OF reports_to ON employee
FOR EACH ROW
EXECUTE FUNCTION fn_validar_hierarquia();
