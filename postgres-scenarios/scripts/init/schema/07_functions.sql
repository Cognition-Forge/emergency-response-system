SET search_path TO public;

CREATE OR REPLACE FUNCTION fn_emergency_inventory_search(
    p_po_line_item_id UUID,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    inventory_id UUID,
    warehouse_id UUID,
    quantity_available NUMERIC,
    soft_available_qty NUMERIC,
    hard_available_qty NUMERIC,
    availability_status TEXT,
    compatibility_score INTEGER,
    urgency_score INTEGER,
    availability_score INTEGER,
    impact_level TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    r_po RECORD;
BEGIN
    SELECT pli.id,
           po.project_id,
           pli.commodity_code_id,
           pli.equipment_id,
           pli.wbs_id,
           pli.contractual_delivery_date,
           pli.forecast_delivery_date,
           ros.ros_date
    INTO r_po
    FROM po_line_items pli
    JOIN purchase_orders po ON po.id = pli.po_id
    LEFT JOIN wbs_ros_dates ros ON ros.wbs_id = pli.wbs_id
    WHERE pli.id = p_po_line_item_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'PO line item % not found', p_po_line_item_id;
    END IF;

    RETURN QUERY
    WITH reservations AS (
      SELECT ir.inventory_id,
             MIN(ir.required_by_date) AS next_required_by,
             MAX(ir.priority_level) FILTER (WHERE ir.reserved_quantity > 0) AS max_priority,
             BOOL_OR(ir.can_reassign) AS any_reassignable
      FROM inventory_reservations ir
      GROUP BY ir.inventory_id
    )
    SELECT
        wi.id AS inventory_id,
        wi.warehouse_id,
        wi.quantity_available,
        GREATEST(wi.quantity_available - wi.quantity_reserved, 0) AS soft_available_qty,
        GREATEST(wi.quantity_available - wi.quantity_hard_reserved - wi.safety_stock_level, 0) AS hard_available_qty,
        CASE
            WHEN wi.status <> 'available' THEN 'blocked'
            WHEN wi.quantity_available - wi.quantity_hard_reserved - wi.safety_stock_level > 0 THEN 'free'
            WHEN wi.quantity_available - wi.quantity_reserved > 0 AND COALESCE(res.any_reassignable, FALSE) THEN 'reassignable'
            WHEN wi.quantity_available > wi.safety_stock_level THEN 'emergency_only'
            ELSE 'unavailable'
        END AS availability_status,
        CASE
            WHEN wi.commodity_code_id = r_po.commodity_code_id AND wi.wbs_id = r_po.wbs_id THEN 100
            WHEN wi.commodity_code_id = r_po.commodity_code_id THEN 80
            WHEN wi.equipment_id = r_po.equipment_id AND wi.equipment_id IS NOT NULL THEN 70
            ELSE 0
        END AS compatibility_score,
        CASE
            WHEN r_po.ros_date IS NULL THEN 50
            WHEN res.next_required_by IS NULL THEN 80
            WHEN res.next_required_by <= r_po.ros_date THEN 40
            WHEN res.next_required_by <= r_po.ros_date + INTERVAL '7 days' THEN 60
            ELSE 90
        END AS urgency_score,
        CASE
            WHEN wi.status <> 'available' THEN 10
            WHEN wi.quantity_available - wi.quantity_hard_reserved - wi.safety_stock_level > 0 THEN 100
            WHEN wi.quantity_available - wi.quantity_reserved > 0 THEN 60
            WHEN wi.quantity_available > wi.safety_stock_level THEN 25
            ELSE 5
        END AS availability_score,
        CASE
            WHEN wi.status <> 'available' THEN 'blocked'
            WHEN wi.quantity_available - wi.quantity_hard_reserved - wi.safety_stock_level > 0 THEN 'no_impact'
            WHEN wi.quantity_available - wi.quantity_reserved > 0 THEN 'moderate_impact'
            ELSE 'critical_decision'
        END AS impact_level
    FROM warehouse_inventory wi
    LEFT JOIN reservations res ON res.inventory_id = wi.id
    WHERE wi.project_id = r_po.project_id
      AND (
          (wi.commodity_code_id IS NOT NULL AND wi.commodity_code_id = r_po.commodity_code_id)
          OR (wi.equipment_id IS NOT NULL AND wi.equipment_id = r_po.equipment_id)
      )
    ORDER BY compatibility_score DESC, availability_score DESC
    LIMIT COALESCE(p_limit, 10);

END;
$$;
