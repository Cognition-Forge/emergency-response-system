# Multi-Iteration LLM Call Example

## Scenario: Enhanced Scenario 2 - Regional Multi-Hazard Event
**Context**: Bushfire + flood affecting rural communities with competing agency priorities

---

## ITERATION 1 CALL

### System Prompt
```
You are the emergency accommodation AI coordinator for T2.
Evaluate failed shipment impacts and recommend accommodations with clear business justification.
Prioritize transparency, cite key constraints, and provide an executive-ready summary.

Scenario posture: Balanced.
Weigh schedule recovery and approval complexity evenly.
Accept moderate risk if payback is clear within the project execution timeline.

COMMODITY EXPERTISE:
- Fire Suppression: Consider foam concentrate compatibility, pressure ratings, deployment time
- Flood Response: Account for water level predictions, evacuation timing, equipment weatherproofing
- Agricultural Protection: Factor in livestock welfare, crop preservation windows, seasonal workforce
- Emergency Accommodation: Balance capacity vs setup speed, accessibility for vulnerable populations

Always respond using the structured schema provided.
```

### User Message (Iteration 1)
```json
{
  "scenario": "scenario2",
  "iteration": 1,
  "search_config": {
    "max_iterations": 3,
    "time_window_type": "weekly",
    "batch_size_per_iteration": 12,
    "early_stopping_threshold": 8,
    "search_order": "availability_first",
    "risk_tolerance": "moderate",
    "approval_preference": "minimize"
  },
  "failed_items": [
    {
      "scn_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "line_item_id": "c3d4e5f6-g7h8-9012-cdef-345678901234",
      "description": "Class A Foam Concentrate for Bushfire Suppression",
      "quantity": "8000",
      "unit_of_measure": "LITRE",
      "priority": "critical",
      "ros_date": "2024-06-01",
      "commodity_code": "COM-FIRE-FOAM-CLASSA",
      "equipment_tag": null
    },
    {
      "scn_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "line_item_id": "d4e5f6g7-h8i9-0123-defg-456789012345",
      "description": "Portable Flood Barriers - Modular System",
      "quantity": "2500",
      "unit_of_measure": "METRE",
      "priority": "critical",
      "ros_date": "2024-06-01",
      "commodity_code": "COM-FLOOD-BARRIER-MOD",
      "equipment_tag": "FLD-BAR-001"
    },
    {
      "scn_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "line_item_id": "e5f6g7h8-i9j0-1234-efgh-567890123456",
      "description": "Emergency Livestock Feed Supply",
      "quantity": "15000",
      "unit_of_measure": "KG",
      "priority": "high",
      "ros_date": "2024-06-01",
      "commodity_code": "COM-LIVESTOCK-FEED-EMERG",
      "equipment_tag": null
    },
    {
      "scn_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "line_item_id": "f6g7h8i9-j0k1-2345-fghi-678901234567",
      "description": "Rapid Deployment Evacuation Centers",
      "quantity": "45",
      "unit_of_measure": "UNIT",
      "priority": "high",
      "ros_date": "2024-06-01",
      "commodity_code": "COM-EVAC-CENTER-RAPID",
      "equipment_tag": "EVAC-001"
    }
  ],
  "inventory_options": [
    {
      "inventory_id": "a1111111-2222-3333-4444-555555555555",
      "warehouse_id": "w1111111-bbbb-cccc-dddd-eeeeeeeeeeee",
      "warehouse_name": "Dubbo Regional Emergency Hub",
      "material_description": "Fire Retardant Foam Concentrate - Class B",
      "available_quantity": "6500",
      "reserved_quantity": "1500",
      "soft_available_quantity": "5000",
      "hard_available_quantity": "5000",
      "approval_requirement": "supervisor",
      "impact_level": "minor_impact",
      "estimated_recovery_days": 5,
      "risk_summary": "Next required: 2024-06-15 | Priority: 60",
      "distance_km": 125.3
    },
    {
      "inventory_id": "b2222222-3333-4444-5555-666666666666",
      "warehouse_id": "w2222222-cccc-dddd-eeee-ffffffffffff",
      "warehouse_name": "Orange Agricultural Response Centre",
      "material_description": "Modular Flood Defense System - Heavy Duty",
      "available_quantity": "1800",
      "reserved_quantity": "200",
      "soft_available_quantity": "1600",
      "hard_available_quantity": "1600",
      "approval_requirement": "none",
      "impact_level": "no_impact",
      "estimated_recovery_days": 0,
      "risk_summary": "No downstream reservations",
      "distance_km": 89.7
    },
    {
      "inventory_id": "c3333333-4444-5555-6666-777777777777",
      "warehouse_id": "w3333333-dddd-eeee-ffff-000000000000",
      "warehouse_name": "Wagga Wagga Emergency Logistics",
      "material_description": "Premium Livestock Feed - Emergency Grade",
      "available_quantity": "8500",
      "reserved_quantity": "500",
      "soft_available_quantity": "8000",
      "hard_available_quantity": "8000",
      "approval_requirement": "supervisor",
      "impact_level": "minor_impact",
      "estimated_recovery_days": 7,
      "risk_summary": "Next required: 2024-06-20 | Priority: 45",
      "distance_km": 178.2
    },
    {
      "inventory_id": "d4444444-5555-6666-7777-888888888888",
      "warehouse_id": "w1111111-bbbb-cccc-dddd-eeeeeeeeeeee",
      "warehouse_name": "Dubbo Regional Emergency Hub",
      "material_description": "Rapid Assembly Evacuation Shelter - 200 person",
      "available_quantity": "22",
      "reserved_quantity": "2",
      "soft_available_quantity": "20",
      "hard_available_quantity": "20",
      "approval_requirement": "none",
      "impact_level": "no_impact",
      "estimated_recovery_days": 0,
      "risk_summary": "No downstream reservations",
      "distance_km": 125.3
    }
  ],
  "prior_decisions": []
}
```

### Response from Iteration 1
```json
{
  "continue_search": true,
  "reasoning": "Partial coverage achieved for flood barriers (64% coverage with 1600m vs 2500m needed) and evacuation centers (44% coverage with 20 units vs 45 needed). Fire suppression has compatibility issue - Class B foam available vs Class A required. Livestock feed coverage at 53% (8000kg vs 15000kg needed). Balanced approach suggests continuing search for better fire suppression match and improved coverage ratios.",
  "viable_options": [
    {
      "inventory_id": "b2222222-3333-4444-5555-666666666666",
      "summary": "Orange flood barriers provide 64% coverage with immediate availability and no approvals",
      "impact_level": "no_impact",
      "confidence": 0.90,
      "approvals_required": [],
      "trade_offs": ["900m shortfall in flood protection"],
      "score": 8.4
    },
    {
      "inventory_id": "d4444444-5555-6666-7777-888888888888",
      "summary": "Dubbo evacuation centers cover 44% of requirement with rapid deployment capability",
      "impact_level": "no_impact",
      "confidence": 0.85,
      "approvals_required": [],
      "trade_offs": ["25-unit shortfall", "200-person capacity per unit may exceed local needs"],
      "score": 7.6
    },
    {
      "inventory_id": "c3333333-4444-5555-6666-777777777777",
      "summary": "Wagga livestock feed provides 53% coverage for agricultural protection",
      "impact_level": "minor_impact",
      "confidence": 0.80,
      "approvals_required": ["supervisor"],
      "trade_offs": ["7000kg feed gap", "7-day recovery impact", "Supervisor approval required"],
      "score": 6.8
    }
  ],
  "discarded_reasons": [
    "Class B foam incompatible with Class A bushfire suppression requirements - chemical formulation mismatch could reduce effectiveness"
  ]
}
```

---

## ITERATION 2 CALL

### User Message (Iteration 2)
```json
{
  "scenario": "scenario2",
  "iteration": 2,
  "search_config": {
    "max_iterations": 3,
    "time_window_type": "weekly",
    "batch_size_per_iteration": 12,
    "early_stopping_threshold": 8,
    "search_order": "availability_first",
    "risk_tolerance": "moderate",
    "approval_preference": "minimize"
  },
  "failed_items": [
    {
      "scn_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "line_item_id": "c3d4e5f6-g7h8-9012-cdef-345678901234",
      "description": "Class A Foam Concentrate for Bushfire Suppression",
      "quantity": "8000",
      "unit_of_measure": "LITRE",
      "priority": "critical",
      "ros_date": "2024-06-01",
      "commodity_code": "COM-FIRE-FOAM-CLASSA",
      "equipment_tag": null
    },
    {
      "scn_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "line_item_id": "d4e5f6g7-h8i9-0123-defg-456789012345",
      "description": "Portable Flood Barriers - Modular System",
      "quantity": "2500",
      "unit_of_measure": "METRE",
      "priority": "critical",
      "ros_date": "2024-06-01",
      "commodity_code": "COM-FLOOD-BARRIER-MOD",
      "equipment_tag": "FLD-BAR-001"
    },
    {
      "scn_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "line_item_id": "e5f6g7h8-i9j0-1234-efgh-567890123456",
      "description": "Emergency Livestock Feed Supply",
      "quantity": "15000",
      "unit_of_measure": "KG",
      "priority": "high",
      "ros_date": "2024-06-01",
      "commodity_code": "COM-LIVESTOCK-FEED-EMERG",
      "equipment_tag": null
    },
    {
      "scn_id": "b2c3d4e5-f6g7-8901-bcde-f23456789012",
      "line_item_id": "f6g7h8i9-j0k1-2345-fghi-678901234567",
      "description": "Rapid Deployment Evacuation Centers",
      "quantity": "45",
      "unit_of_measure": "UNIT",
      "priority": "high",
      "ros_date": "2024-06-01",
      "commodity_code": "COM-EVAC-CENTER-RAPID",
      "equipment_tag": "EVAC-001"
    }
  ],
  "inventory_options": [
    {
      "inventory_id": "e5555555-6666-7777-8888-999999999999",
      "warehouse_id": "w4444444-eeee-ffff-0000-111111111111",
      "warehouse_name": "Albury Border Emergency Facility",
      "material_description": "Class A Fire Suppression Foam - Concentrated",
      "available_quantity": "9500",
      "reserved_quantity": "500",
      "soft_available_quantity": "9000",
      "hard_available_quantity": "9000",
      "approval_requirement": "manager",
      "impact_level": "moderate_impact",
      "estimated_recovery_days": 12,
      "risk_summary": "Next required: 2024-06-10 | Priority: 85",
      "distance_km": 267.4
    },
    {
      "inventory_id": "f6666666-7777-8888-9999-aaaaaaaaaaaa",
      "warehouse_id": "w2222222-cccc-dddd-eeee-ffffffffffff",
      "warehouse_name": "Orange Agricultural Response Centre",
      "material_description": "Supplementary Flood Barrier Extensions",
      "available_quantity": "1200",
      "reserved_quantity": "0",
      "soft_available_quantity": "1200",
      "hard_available_quantity": "1200",
      "approval_requirement": "supervisor",
      "impact_level": "minor_impact",
      "estimated_recovery_days": 4,
      "risk_summary": "Next required: 2024-06-25 | Priority: 35",
      "distance_km": 89.7
    },
    {
      "inventory_id": "g7777777-8888-9999-aaaa-bbbbbbbbbbbb",
      "warehouse_id": "w5555555-ffff-0000-1111-222222222222",
      "warehouse_name": "Tamworth Agricultural Hub",
      "material_description": "High-Protein Emergency Livestock Feed",
      "available_quantity": "12000",
      "reserved_quantity": "2000",
      "soft_available_quantity": "10000",
      "hard_available_quantity": "10000",
      "approval_requirement": "none",
      "impact_level": "no_impact",
      "estimated_recovery_days": 0,
      "risk_summary": "No downstream reservations",
      "distance_km": 198.5
    },
    {
      "inventory_id": "h8888888-9999-aaaa-bbbb-cccccccccccc",
      "warehouse_id": "w6666666-0000-1111-2222-333333333333",
      "warehouse_name": "Broken Hill Remote Response",
      "material_description": "Mobile Command & Evacuation Complex - 500 person",
      "available_quantity": "15",
      "reserved_quantity": "0",
      "soft_available_quantity": "15",
      "hard_available_quantity": "15",
      "approval_requirement": "executive",
      "impact_level": "critical_decision",
      "estimated_recovery_days": 21,
      "risk_summary": "Next required: 2024-05-30 | Priority: 95",
      "distance_km": 445.8
    },
    {
      "inventory_id": "i9999999-aaaa-bbbb-cccc-dddddddddddd",
      "warehouse_id": "w3333333-dddd-eeee-ffff-000000000000",
      "warehouse_name": "Wagga Wagga Emergency Logistics",
      "material_description": "Rapid Setup Evacuation Pods - 50 person capacity",
      "available_quantity": "85",
      "reserved_quantity": "5",
      "soft_available_quantity": "80",
      "hard_available_quantity": "80",
      "approval_requirement": "supervisor",
      "impact_level": "minor_impact",
      "estimated_recovery_days": 6,
      "risk_summary": "Next required: 2024-06-18 | Priority: 50",
      "distance_km": 178.2
    }
  ],
  "prior_decisions": [
    {
      "continue_search": true,
      "reasoning": "Partial coverage achieved for flood barriers (64% coverage with 1600m vs 2500m needed) and evacuation centers (44% coverage with 20 units vs 45 needed). Fire suppression has compatibility issue - Class B foam available vs Class A required. Livestock feed coverage at 53% (8000kg vs 15000kg needed). Balanced approach suggests continuing search for better fire suppression match and improved coverage ratios.",
      "viable_options": [
        {
          "inventory_id": "b2222222-3333-4444-5555-666666666666",
          "summary": "Orange flood barriers provide 64% coverage with immediate availability and no approvals",
          "impact_level": "no_impact",
          "confidence": 0.90,
          "approvals_required": [],
          "trade_offs": ["900m shortfall in flood protection"],
          "score": 8.4
        },
        {
          "inventory_id": "d4444444-5555-6666-7777-888888888888",
          "summary": "Dubbo evacuation centers cover 44% of requirement with rapid deployment capability",
          "impact_level": "no_impact",
          "confidence": 0.85,
          "approvals_required": [],
          "trade_offs": ["25-unit shortfall", "200-person capacity per unit may exceed local needs"],
          "score": 7.6
        },
        {
          "inventory_id": "c3333333-4444-5555-6666-777777777777",
          "summary": "Wagga livestock feed provides 53% coverage for agricultural protection",
          "impact_level": "minor_impact",
          "confidence": 0.80,
          "approvals_required": ["supervisor"],
          "trade_offs": ["7000kg feed gap", "7-day recovery impact", "Supervisor approval required"],
          "score": 6.8
        }
      ],
      "discarded_reasons": [
        "Class B foam incompatible with Class A bushfire suppression requirements - chemical formulation mismatch could reduce effectiveness"
      ]
    }
  ]
}
```

### Response from Iteration 2
```json
{
  "continue_search": false,
  "reasoning": "Iteration 2 provides comprehensive coverage improvements. Albury Class A foam matches technical requirement with 112% coverage (9000L vs 8000L needed) despite manager approval. Combined flood barriers from Orange primary (1600m) + extensions (1200m) = 2800m total, exceeding requirement by 12%. Tamworth livestock feed provides 67% coverage (10000kg vs 15000kg) with no approvals. Wagga evacuation pods offer better size fit (50-person vs 200-person) and 178% coverage (80 units vs 45 needed). Early stopping threshold reached with 8 viable options total.",
  "viable_options": [
    {
      "inventory_id": "e5555555-6666-7777-8888-999999999999",
      "summary": "Albury Class A foam provides 112% coverage with correct chemical specification for bushfire suppression",
      "impact_level": "moderate_impact",
      "confidence": 0.95,
      "approvals_required": ["manager"],
      "trade_offs": ["Manager approval required", "12-day recovery impact", "Distant location"],
      "score": 8.8
    },
    {
      "inventory_id": "f6666666-7777-8888-9999-aaaaaaaaaaaa",
      "summary": "Orange flood barrier extensions complement Iteration 1 selection for complete protection",
      "impact_level": "minor_impact",
      "confidence": 0.90,
      "approvals_required": ["supervisor"],
      "trade_offs": ["Combined with Iteration 1: 2800m total exceeds 2500m requirement"],
      "score": 8.6
    },
    {
      "inventory_id": "g7777777-8888-9999-aaaa-bbbbbbbbbbbb",
      "summary": "Tamworth high-protein feed improves livestock welfare with 67% coverage and immediate availability",
      "impact_level": "no_impact",
      "confidence": 0.88,
      "approvals_required": [],
      "trade_offs": ["5000kg feed gap remains", "Superior nutritional profile offsets quantity shortfall"],
      "score": 8.2
    },
    {
      "inventory_id": "i9999999-aaaa-bbbb-cccc-dddddddddddd",
      "summary": "Wagga evacuation pods provide optimal capacity sizing with 178% coverage for flexible deployment",
      "impact_level": "minor_impact",
      "confidence": 0.92,
      "approvals_required": ["supervisor"],
      "trade_offs": ["Better capacity utilization than 200-person units", "6-day recovery impact"],
      "score": 8.7
    }
  ],
  "discarded_reasons": [
    "Broken Hill mobile complex requires executive approval with critical impact for marginal benefit over existing options",
    "Early stopping threshold of 8 viable options reached across both iterations"
  ]
}
```

---

## FINAL RECOMMENDATION CALL

### User Message (Final Recommendation)
```json
{
  "scenario": "scenario2",
  "search_config": {
    "max_iterations": 3,
    "time_window_type": "weekly",
    "batch_size_per_iteration": 12,
    "early_stopping_threshold": 8,
    "search_order": "availability_first",
    "risk_tolerance": "moderate",
    "approval_preference": "minimize"
  },
  "iteration_history": [
    {
      "iteration": 1,
      "failed_items": [...], // Same as iteration 1
      "inventory_options": [...], // Same as iteration 1
      "decision": {...} // Same as iteration 1 response
    },
    {
      "iteration": 2,
      "failed_items": [...], // Same as iteration 2
      "inventory_options": [...], // Same as iteration 2
      "decision": {...} // Same as iteration 2 response
    }
  ],
  "collated_options": [
    // All viable options from both iterations
    {
      "inventory_id": "b2222222-3333-4444-5555-666666666666",
      "summary": "Orange flood barriers provide 64% coverage with immediate availability and no approvals",
      "impact_level": "no_impact",
      "confidence": 0.90,
      "approvals_required": [],
      "trade_offs": ["900m shortfall in flood protection"],
      "score": 8.4
    },
    // ... other options from both iterations
  ]
}
```

### Final Recommendation Response
```json
{
  "primary_option": {
    "inventory_id": "e5555555-6666-7777-8888-999999999999",
    "summary": "Albury Class A foam - critical bushfire suppression capability with technical specification match",
    "impact_level": "moderate_impact",
    "confidence": 0.95,
    "approvals_required": ["manager"],
    "trade_offs": ["Manager approval required", "12-day recovery timeline"],
    "score": 8.8
  },
  "alternatives": [
    {
      "inventory_id": "i9999999-aaaa-bbbb-cccc-dddddddddddd",
      "summary": "Wagga evacuation pods - optimal sizing with 178% coverage",
      "impact_level": "minor_impact",
      "confidence": 0.92,
      "approvals_required": ["supervisor"],
      "trade_offs": ["Better capacity fit than large units"],
      "score": 8.7
    },
    {
      "inventory_id": "f6666666-7777-8888-9999-aaaaaaaaaaaa",
      "summary": "Orange flood barrier extensions - completes flood protection when combined with Iteration 1",
      "impact_level": "minor_impact",
      "confidence": 0.90,
      "approvals_required": ["supervisor"],
      "trade_offs": ["Requires coordination with first barrier deployment"],
      "score": 8.6
    }
  ],
  "executive_summary": "Multi-hazard accommodation strategy addresses 4 critical failure categories with combined 100%+ coverage through coordinated deployment. Primary challenge: Class A foam requires manager approval due to moderate impact on training programs. Flood protection achieves 112% coverage through two-source strategy. Evacuation capacity exceeds requirement with better sizing. Livestock feed provides 67% coverage with premium nutrition offsetting quantity gap.",
  "risk_mitigation": [
    "Expedite manager approval for Class A foam given critical bushfire suppression priority",
    "Coordinate Orange flood barrier deployments (primary + extensions) for seamless protection",
    "Establish backup livestock feed sourcing for remaining 5000kg requirement",
    "Deploy evacuation pods in distributed pattern to optimize local population coverage"
  ]
}
```

## Key Multi-Iteration Insights

1. **Learning Between Iterations**: AI remembers previous decisions and builds upon them
2. **Coverage Optimization**: Combines options across iterations (flood barriers: 1600m + 1200m = 2800m)
3. **Technical Compatibility**: Rejects Class B foam in favor of proper Class A specification
4. **Approval Complexity Management**: Balances coverage benefits against approval overhead
5. **Early Stopping Logic**: Recognizes when sufficient viable options have been found
6. **Integrated Recommendations**: Final recommendation considers entire search history

This demonstrates how the iterative approach creates sophisticated, realistic decision-making that would be highly engaging for demonstrations.