-- 4. A base original do Chinook possui uma coluna Total na tabela Invoice representada de forma redundante 
-- com as informações contidas nas colunas UnitPrice e Quantity na tabela InvoiceLine. Podemos identificar 
-- nesse caso uma regra semântica onde o valor Total de um Invoice deve ser igual à soma de 
-- UnitPrice * Quantity de todos os registros de InvoiceLine relacionados a um Invoice. 
-- Implementar uma solução que garanta a integridade dessa regra.

CREATE OR REPLACE FUNCTION update_total_invoice()
RETURNS TRIGGER
AS $$
DECLARE
    invoice_id_afetado INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        invoice_id_afetado := OLD.invoice_id;
    ELSE
        invoice_id_afetado := NEW.invoice_id;
    END IF;
    UPDATE invoice
    SET total = COALESCE(
        (
            SELECT SUM(unit_price * quantity)
            FROM invoice_line
            WHERE invoice_id = invoice_id_afetado
        ),
        0
    )
    WHERE invoice_id = invoice_id_afetado;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_total_invoice
AFTER INSERT OR UPDATE OR DELETE
on invoice_line
FOR EACH ROW
EXECUTE FUNCTION update_total_invoice();
