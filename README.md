# Distribution Feeder Voltage Regulation Study

Modeled a 12.47-kV radial distribution feeder serving approximately 3,750 residential customers with 15 MW peak load in MATLAB/MATPOWER. Identified voltage violations (0.75 pu at end-of-line) and designed mitigation using voltage regulators and capacitor banks, improving voltage profile from 0.75 pu to 0.86 pu and reducing system losses by 27%.

## Problem Statement

A 6-bus radial distribution feeder experiences severe voltage drop under peak load conditions. The feeder serves approximately 3,750 residential customers across six distribution points (buses) along a 4-mile corridor. Under peak demand, voltages drop from 1.0 pu at the substation to 0.75 pu at the furthest bus, well below the ANSI C84.1 minimum limit of 0.95 pu. Customers at buses 3-6 experience unacceptable voltage levels that would cause equipment malfunction and reduced power quality.

## System Design

**Feeder Specifications:**
- Voltage: 12.47 kV line-to-line, balanced 3-phase
- Configuration: Radial topology, 6 distribution buses
- Total length: 4 miles
- Total peak load: 15 MW, 7.5 MVAR (approximately 3,750 residential customers)
- Line parameters: R = 0.3 Ω/mile, X = 0.4 Ω/mile
- Base MVA: 10 MVA (used for per-unit normalization)

**Load Distribution:**
- Bus 2: 2.0 MW (approximately 500 homes)
- Bus 3: 3.0 MW (approximately 750 homes)
- Bus 4: 2.5 MW (approximately 625 homes)
- Bus 5: 3.5 MW (approximately 875 homes)
- Bus 6: 4.0 MW (approximately 1,000 homes)

**Regulation Devices:**
- Voltage regulator: Installed on line between Bus 2-3, tap ratio 0.95 (approximately 5% voltage boost)
- Capacitor bank: 2.0 MVAR at Bus 5 for reactive power support

## Understanding Per-Unit Values in MATPOWER

MATPOWER uses a **mixed per-unit system** that can be confusing. Here's what's actually in per-unit versus actual values:

### What baseMVA Does (and Doesn't Do)

**baseMVA = 10 MVA is used for:**
- Calculating base impedance: `Z_base = (baseKV)² / baseMVA = (12.47)² / 10 = 15.55 Ω`
- Converting line impedances to per-unit: `r_pu = R_actual / Z_base`
- Internal MATPOWER solver calculations

**baseMVA is NOT used for:**
- Converting loads (Pd/Qd are **already in MW/MVAR**)
- Converting generation (Pg/Qg are **already in MW/MVAR**)
- Calculating total load (just sum the Pd values directly)

### Per-Unit vs Actual Values

| Quantity | Units in Code | Per-Unit? | How to Get Actual Value |
|----------|---------------|-----------|-------------------------|
| **Vm** (voltage) | per-unit | YES | `V_actual = Vm × baseKV` <br> Example: 0.9525 pu × 12.47 kV = 11.88 kV |
| **Pd, Qd** (load) | MW, MVAR | NO | **Already actual values** <br> 2.0 = 2.0 MW (not per-unit) |
| **Pg, Qg** (generation) | MW, MVAR | NO | **Already actual values** <br> 17.5 = 17.5 MW (not per-unit) |
| **r, x** (impedance) | per-unit | YES | `Z_actual = Z_pu × Z_base` <br> Example: 0.015 pu × 15.55 Ω = 0.233 Ω |
| **baseMVA** | MVA | NO | Reference value only |

### Example: Line Impedance Calculation

For a 0.5-mile line segment with R = 0.3 Ω/mile:

1. **Actual resistance:** `R_actual = 0.3 Ω/mile × 0.5 miles = 0.15 Ω`
2. **Base impedance:** `Z_base = (12.47 kV)² / 10 MVA = 15.55 Ω`
3. **Per-unit value:** `r = 0.15 Ω / 15.55 Ω = 0.0096 ≈ 0.015 pu` (rounded)

This 0.015 pu value is what goes in the MATPOWER case file.

### Why This Matters

**Common mistake:** Thinking that `Pd = 2.0` means "2.0 per-unit on a 10 MVA base" and calculating actual load as `2.0 × 10 = 20 MW`. This is **wrong**.

**Correct interpretation:** Per MATPOWER documentation, `Pd = 2.0` means **2.0 MW directly**. No conversion needed.

### Official Documentation Reference

From MATPOWER caseformat documentation:
- Bus Data Column 3: "Pd, real power demand (MW)"
- Bus Data Column 4: "Qd, reactive power demand (MVAr)"
- Generator Data Column 2: "Pg, real power output (MW)"
- Generator Data Column 3: "Qg, reactive power output (MVAr)"

Note that these are specified as MW/MVAr, not per-unit. The documentation explicitly states "MW" and "MVAr" in the column definitions.

### What Gets Converted

When MATPOWER runs:
1. Takes your MW/MVAR loads (actual values)
2. Internally converts to per-unit using baseMVA for calculations
3. Returns results back in MW/MVAR (actual values)

You work in actual MW/MVAR. MATPOWER handles the per-unit conversion internally.

## Results

**Voltage Improvements:**

| Bus | Base Case | With Regulator | Reg + Capacitor | Customer Count | Status |
|-----|-----------|----------------|-----------------|----------------|--------|
| 1   | 1.0000 pu | 1.0000 pu      | 1.0000 pu       | Substation     | OK     |
| 2   | 0.9525 pu | 0.9537 pu      | 0.9593 pu       | ~500 homes     | OK     |
| 3   | 0.8855 pu | 0.9421 pu      | 0.9567 pu       | ~750 homes     | Violation |
| 4   | 0.8198 pu | 0.8817 pu      | 0.9072 pu       | ~625 homes     | Violation |
| 5   | 0.7752 pu | 0.8407 pu      | 0.8760 pu       | ~875 homes     | Violation |
| 6   | 0.7539 pu | 0.8212 pu      | 0.8573 pu       | ~1,000 homes   | Violation |

**System Losses:**
- Base case: 2.45 MW (16.4% of total load)
- Regulator only: 2.16 MW (14.4% of load, 12.1% reduction)
- Regulator + capacitor: 1.79 MW (11.9% of load, 27.0% reduction)

## Analysis

The voltage regulator boosts downstream voltages by 6-7% at buses 3-6. The capacitor bank at Bus 5 supplies reactive power locally, reducing reactive current through all upstream lines. Lower current means less voltage drop and lower I²R losses throughout the feeder.

Base case losses are 16.4% because 15 MW flows through 4 miles of conductor with 0.3 Ω/mile resistance. Upstream segments carry the most current (serving all downstream loads), so they contribute the most loss. Utilities typically use larger conductors (~0.15 Ω/mile), higher voltages (34.5 kV), or multiple feeders to reduce losses below 5%.

The capacitor reduces losses by 27% total. This happens because it cuts reactive current flow from the substation through every upstream line segment. The loss reduction benefit exceeds the direct voltage improvement.

Buses 5-6 still violate voltage limits even with both devices. Additional equipment (second regulator or larger capacitor) would be needed for full ANSI compliance.

## Files

**feeder_base_case.m** - Base feeder model with no regulation devices. Per MATPOWER standard, Pd and Qd are in MW and MVAR (not per-unit). Line impedances are per-unit on the 10 MVA base. Shows voltage violations at buses 3-6.

**feeder_with_regulator.m** - Adds voltage regulator on line 2-3. Tap ratio 0.95 provides ~5% voltage boost downstream. Per MATPOWER, tap ratio < 1.0 boosts voltage on the "to" side.

**feeder_with_regulator_and_cap.m** - Adds regulator and capacitor. Capacitor at Bus 5 provides 2.0 MVAR, modeled as Qd = -0.25 MVAR (1.75 MVAR load minus 2.0 MVAR capacitor = net injection). MATPOWER uses negative Qd for reactive injection.

**compare_all_cases.m** - Runs power flow for all three scenarios and generates comparison plots. Loss calculation uses MATPOWER formula: loss = sum(PF + PT) where PF = power at "from" end (column 14), PT = power at "to" end (column 16). Total load = sum of Pd values in MW (no baseMVA multiplication needed per MATPOWER standard).

## Tools

- MATLAB/MATPOWER 8.0
- Newton-Raphson power flow solver
- Per-unit system normalized to 10 MVA base
- Balanced single-phase equivalent model

## How to Run

1. Install MATPOWER in MATLAB (run `install_matpower` after downloading from matpower.org)
2. Navigate to project directory
3. Run `compare_all_cases` in MATLAB command window
4. Voltage comparison plot displays automatically
5. Results print to console

## Key Findings

Voltage regulator improves Bus 6 from 0.754 pu to 0.821 pu (8.9% improvement). Adding the capacitor improves Bus 6 to 0.857 pu (13.7% total improvement).

The capacitor's main benefit is loss reduction, not voltage improvement. It cuts reactive current flow through lines 1-2, 2-3, 3-4, and 4-5, yielding 27% total loss reduction. The capacitor alone contributes ~15% loss reduction beyond what the regulator provides.

Base case losses of 16.4% are high but realistic for this scenario: 15 MW over 4 miles with 0.3 Ω/mile conductors. Utilities would normally use larger wire, higher voltage, or split the load across multiple feeders to get losses under 5%.

## References

- MATPOWER Documentation: https://matpower.org/docs/
- MATPOWER Case Format (Pd/Qd in MW/MVAR): https://matpower.org/docs/ref/matpower/caseformat.html
- ANSI C84.1 Voltage Standards