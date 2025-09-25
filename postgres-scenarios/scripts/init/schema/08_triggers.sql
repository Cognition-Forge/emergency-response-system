SET search_path TO public;

CREATE OR REPLACE FUNCTION trg_record_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_project_id UUID;
BEGIN
    v_project_id := NULL;
    IF TG_OP IN ('INSERT', 'UPDATE') AND NEW IS NOT NULL THEN
        v_project_id := NULLIF(to_jsonb(NEW)->>'project_id', '')::UUID;
    END IF;
    IF v_project_id IS NULL AND OLD IS NOT NULL THEN
        v_project_id := NULLIF(to_jsonb(OLD)->>'project_id', '')::UUID;
    END IF;

    INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, project_id)
    VALUES (
        TG_TABLE_NAME,
        CASE WHEN TG_OP = 'INSERT' THEN NEW.id ELSE OLD.id END,
        TG_OP,
        CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE to_jsonb(OLD) END,
        CASE WHEN TG_OP = 'DELETE' THEN NULL ELSE to_jsonb(NEW) END,
        v_project_id
    );
    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION attach_audit_trigger(p_table TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE format('DROP TRIGGER IF EXISTS %I_audit ON %s', p_table, p_table);
    EXECUTE format('CREATE TRIGGER %I_audit
        AFTER INSERT OR UPDATE OR DELETE ON %s
        FOR EACH ROW EXECUTE FUNCTION trg_record_audit()', p_table, p_table);
END;
$$;

SELECT attach_audit_trigger(t.table_name)
FROM (
    VALUES
        ('projects'),
        ('purchase_orders'),
        ('po_line_items'),
        ('scns'),
        ('scn_line_items'),
        ('receipts'),
        ('receipt_line_items'),
        ('warehouse_inventory'),
        ('inventory_reservations'),
        ('fmrs'),
        ('fmr_line_items'),
        ('emergency_incidents'),
        ('emergency_accommodations')
) AS t(table_name);
