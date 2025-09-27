# Option A Enhanced LLM Call Example

## Complete LLM Request Structure

Here's what a complete LLM call would look like for an enhanced Scenario 1 (Hurricane evacuation) with realistic scale and commodity diversity:

### System Prompt (Instructions)
```
You are the emergency accommodation AI coordinator for T2.
Evaluate failed shipment impacts and recommend accommodations with clear business justification.
Prioritize transparency, cite key constraints, and provide an executive-ready summary.

Scenario posture: Conservative.
Minimize approval overhead and protect schedule commitments above all else.
Recommend continuing search unless options meet strict compliance and risk thresholds.

COMMODITY EXPERTISE:
- Emergency Shelters: Consider setup time, weather resistance, capacity per family unit
- Medical Supplies: Prioritize life-safety critical items, cold chain requirements
- Power Generation: Account for fuel dependencies, noise levels, maintenance expertise
- Water Systems: Factor in daily consumption rates, treatment capacity, distribution logistics
- Communications: Ensure interoperability, battery life, coverage area requirements
- Food & Logistics: Consider shelf life, dietary restrictions, preparation requirements

Always respond using the structured schema provided.
```

### User Message (JSON Payload)
```json
{
  "scenario": "scenario1",
  "iteration": 1,
  "search_config": {
    "max_iterations": 2,
    "time_window_type": "weekly",
    "batch_size_per_iteration": 15,
    "early_stopping_threshold": 4,
    "search_order": "urgency_first",
    "risk_tolerance": "conservative",
    "approval_preference": "minimize"
  },
  "failed_items": [
    {
      "scn_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "line_item_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "description": "Emergency Family Shelter Kit",
      "quantity": "2500",
      "unit_of_measure": "KIT",
      "priority": "critical",
      "ros_date": "2024-05-12",
      "commodity_code": "COM-EMERG-SHELTER-FAMILY",
      "equipment_tag": null
    },
    {
      "scn_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "line_item_id": "c3d4e5f6-g7h8-9012-cdef-345678901234",
      "description": "Portable Power Generation Unit 5kW",
      "quantity": "150",
      "unit_of_measure": "UNIT",
      "priority": "critical",
      "ros_date": "2024-05-12",
      "commodity_code": "COM-POWER-GEN-5KW",
      "equipment_tag": "PWR-GEN-001"
    },
    {
      "scn_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "line_item_id": "d4e5f6g7-h8i9-0123-defg-456789012345",
      "description": "Water Purification System - Mobile",
      "quantity": "25",
      "unit_of_measure": "SYSTEM",
      "priority": "critical",
      "ros_date": "2024-05-12",
      "commodity_code": "COM-WATER-PURIFY-MOB",
      "equipment_tag": "WAT-PUR-001"
    },
    {
      "scn_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "line_item_id": "e5f6g7h8-i9j0-1234-efgh-567890123456",
      "description": "Emergency Medical Supply Cache",
      "quantity": "75",
      "unit_of_measure": "CACHE",
      "priority": "critical",
      "ros_date": "2024-05-12",
      "commodity_code": "COM-MED-EMERGENCY-CACHE",
      "equipment_tag": null
    },
    {
      "scn_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "line_item_id": "f6g7h8i9-j0k1-2345-fghi-678901234567",
      "description": "Communications Equipment Package",
      "quantity": "40",
      "unit_of_measure": "PKG",
      "priority": "high",
      "ros_date": "2024-05-12",
      "commodity_code": "COM-COMM-EMERGENCY-PKG",
      "equipment_tag": "COMM-001"
    }
  ],
  "inventory_options": [
    {
      "inventory_id": "11111111-2222-3333-4444-555555555555",
      "warehouse_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "warehouse_name": "Newcastle Regional Emergency Depot",
      "material_description": "Emergency Family Shelter Kit",
      "available_quantity": "1800",
      "reserved_quantity": "200",
      "soft_available_quantity": "1600",
      "hard_available_quantity": "1600",
      "approval_requirement": "none",
      "impact_level": "no_impact",
      "estimated_recovery_days": 0,
      "risk_summary": "No downstream reservations",
      "distance_km": 45.2
    },
    {
      "inventory_id": "22222222-3333-4444-5555-666666666666",
      "warehouse_id": "bbbbbbbb-cccc-dddd-eeee-ffffffffffff",
      "warehouse_name": "Sydney Metropolitan Reserve",
      "material_description": "Emergency Family Shelter Kit - Weatherproof",
      "available_quantity": "950",
      "reserved_quantity": "50",
      "soft_available_quantity": "900",
      "hard_available_quantity": "900",
      "approval_requirement": "supervisor",
      "impact_level": "minor_impact",
      "estimated_recovery_days": 3,
      "risk_summary": "Next required: 2024-06-15 | Priority: 65",
      "distance_km": 185.7
    },
    {
      "inventory_id": "33333333-4444-5555-6666-777777777777",
      "warehouse_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "warehouse_name": "Newcastle Regional Emergency Depot",
      "material_description": "Portable Generator 5.5kW Diesel",
      "available_quantity": "85",
      "reserved_quantity": "15",
      "soft_available_quantity": "70",
      "hard_available_quantity": "70",
      "approval_requirement": "none",
      "impact_level": "no_impact",
      "estimated_recovery_days": 0,
      "risk_summary": "No downstream reservations",
      "distance_km": 45.2
    },
    {
      "inventory_id": "44444444-5555-6666-7777-888888888888",
      "warehouse_id": "cccccccc-dddd-eeee-ffff-000000000000",
      "warehouse_name": "Brisbane Emergency Logistics Hub",
      "material_description": "Multi-fuel Power Generation System 7kW",
      "available_quantity": "120",
      "reserved_quantity": "0",
      "soft_available_quantity": "120",
      "hard_available_quantity": "120",
      "approval_requirement": "supervisor",
      "impact_level": "minor_impact",
      "estimated_recovery_days": 5,
      "risk_summary": "Next required: 2024-06-20 | Priority: 45",
      "distance_km": 756.3
    },
    {
      "inventory_id": "55555555-6666-7777-8888-999999999999",
      "warehouse_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "warehouse_name": "Newcastle Regional Emergency Depot",
      "material_description": "Reverse Osmosis Water Treatment Unit",
      "available_quantity": "18",
      "reserved_quantity": "2",
      "soft_available_quantity": "16",
      "hard_available_quantity": "16",
      "approval_requirement": "none",
      "impact_level": "no_impact",
      "estimated_recovery_days": 0,
      "risk_summary": "No downstream reservations",
      "distance_km": 45.2
    },
    {
      "inventory_id": "66666666-7777-8888-9999-aaaaaaaaaaaa",
      "warehouse_id": "dddddddd-eeee-ffff-0000-111111111111",
      "warehouse_name": "Canberra Strategic Reserve",
      "material_description": "Advanced Water Purification System - Trailer Mounted",
      "available_quantity": "12",
      "reserved_quantity": "0",
      "soft_available_quantity": "12",
      "hard_available_quantity": "12",
      "approval_requirement": "manager",
      "impact_level": "moderate_impact",
      "estimated_recovery_days": 14,
      "risk_summary": "Next required: 2024-05-25 | Priority: 85",
      "distance_km": 612.4
    },
    {
      "inventory_id": "77777777-8888-9999-aaaa-bbbbbbbbbbbb",
      "warehouse_id": "bbbbbbbb-cccc-dddd-eeee-ffffffffffff",
      "warehouse_name": "Sydney Metropolitan Reserve",
      "material_description": "Emergency Medical Response Kit - Level 2",
      "available_quantity": "45",
      "reserved_quantity": "5",
      "soft_available_quantity": "40",
      "hard_available_quantity": "40",
      "approval_requirement": "none",
      "impact_level": "no_impact",
      "estimated_recovery_days": 0,
      "risk_summary": "No downstream reservations",
      "distance_km": 185.7
    },
    {
      "inventory_id": "88888888-9999-aaaa-bbbb-cccccccccccc",
      "warehouse_name": "Adelaide Emergency Coordination Centre",
      "warehouse_id": "eeeeeeee-ffff-0000-1111-222222222222",
      "material_description": "Comprehensive Medical Supply Cache - Trauma",
      "available_quantity": "65",
      "reserved_quantity": "10",
      "soft_available_quantity": "55",
      "hard_available_quantity": "55",
      "approval_requirement": "supervisor",
      "impact_level": "minor_impact",
      "estimated_recovery_days": 7,
      "risk_summary": "Next required: 2024-06-01 | Priority: 70",
      "distance_km": 1165.8
    },
    {
      "inventory_id": "99999999-aaaa-bbbb-cccc-dddddddddddd",
      "warehouse_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "warehouse_name": "Newcastle Regional Emergency Depot",
      "material_description": "Satellite Communication System - Deployable",
      "available_quantity": "22",
      "reserved_quantity": "2",
      "soft_available_quantity": "20",
      "hard_available_quantity": "20",
      "approval_requirement": "none",
      "impact_level": "no_impact",
      "estimated_recovery_days": 0,
      "risk_summary": "No downstream reservations",
      "distance_km": 45.2
    },
    {
      "inventory_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "warehouse_id": "cccccccc-dddd-eeee-ffff-000000000000",
      "warehouse_name": "Brisbane Emergency Logistics Hub",
      "material_description": "VHF/UHF Emergency Communications Package",
      "available_quantity": "35",
      "reserved_quantity": "5",
      "soft_available_quantity": "30",
      "hard_available_quantity": "30",
      "approval_requirement": "supervisor",
      "impact_level": "minor_impact",
      "estimated_recovery_days": 4,
      "risk_summary": "Next required: 2024-05-30 | Priority: 55",
      "distance_km": 756.3
    }
  ],
  "prior_decisions": []
}
```

### Expected Response Structure
The AI would respond with structured JSON like:
```json
{
  "continue_search": false,
  "reasoning": "Critical shelter requirement can be fully met using Newcastle depot inventory with 1600 available units covering 64% of need (1600/2500). Power generation can be partially addressed with local 5.5kW units (70 available vs 150 needed). Water treatment partially covered with 16 RO units vs 25 needed. Medical and communications have adequate local coverage. Conservative approach favors Newcastle proximity and zero approval requirements despite coverage gaps.",
  "viable_options": [
    {
      "inventory_id": "11111111-2222-3333-4444-555555555555",
      "summary": "Primary shelter solution from Newcastle depot - covers 64% of critical shelter need with immediate availability and zero approvals",
      "impact_level": "no_impact",
      "confidence": 0.95,
      "approvals_required": [],
      "trade_offs": ["Leaves 900 shelter gap requiring additional sourcing"],
      "score": 9.2
    },
    {
      "inventory_id": "33333333-4444-5555-6666-777777777777",
      "summary": "Local power generation option - covers 47% of power requirement with diesel generators",
      "impact_level": "no_impact",
      "confidence": 0.85,
      "approvals_required": [],
      "trade_offs": ["80-unit power gap", "Diesel dependency", "Higher maintenance"],
      "score": 7.8
    },
    {
      "inventory_id": "55555555-6666-7777-8888-999999999999",
      "summary": "Water treatment coverage - meets 64% of purification requirement with RO systems",
      "impact_level": "no_impact",
      "confidence": 0.90,
      "approvals_required": [],
      "trade_offs": ["9-system shortfall requiring additional sources"],
      "score": 8.1
    }
  ],
  "discarded_reasons": [
    "Sydney shelter option requires supervisor approval for minor coverage improvement",
    "Brisbane power systems require distant logistics and supervisor approval",
    "Canberra water systems need manager approval with 14-day recovery impact",
    "Medical options exceed immediate requirement coverage"
  ]
}
```

## Key Enhancements in Option A

### 1. **Realistic Scale**
- **Before**: 20 shelter kits
- **After**: 2,500 family shelter kits (Hurricane scale)

### 2. **Commodity Diversity**
- **Before**: Single commodity type
- **After**: 5 critical commodity categories (shelter, power, water, medical, communications)

### 3. **Geographic Distribution**
- **Before**: Single warehouse
- **After**: 5 warehouses across Australia with distance calculations

### 4. **Complex Decision Factors**
- **Before**: Simple availability
- **After**: Approval levels, impact assessments, recovery timelines, geographic logistics

### 5. **Enhanced AI Reasoning**
- **Before**: Basic recommendation
- **After**: Multi-criteria analysis with commodity expertise, trade-off evaluation, confidence scoring

### 6. **Realistic Constraints**
- Partial coverage scenarios requiring multiple accommodations
- Geographic trade-offs (proximity vs. approval complexity)
- Downstream impact assessment for reservations
- Equipment compatibility considerations (5kW vs 7kW generators)

This example shows how Option A creates dramatically more realistic and engaging demonstrations while requiring only data enhancements and improved prompts, with no code changes needed.