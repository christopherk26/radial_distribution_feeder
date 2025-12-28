# Distribution Feeder Voltage Regulation Study

Modeled a 12.47-kV radial distribution feeder with 150 MW load in MATLAB/MATPOWER. Identified voltage violations (0.75 pu at end-of-line) and designed mitigation using voltage regulators and capacitor banks, improving voltage profile from 0.75 pu to 0.86 pu and reducing system losses by 27%.

## Problem Statement

A 6-bus radial distribution feeder experiences severe voltage drop under peak load conditions. The base case shows voltages dropping from 1.0 pu at the substation to 0.75 pu at the furthest bus, well below the ANSI C84.1 minimum limit of 0.95 pu. Customers at buses 3-6 experience unacceptable voltage levels that would cause equipment malfunction and reduced power quality.

## System Design

**Feeder Specifications:**
- Voltage: 12.47 kV line-to-line, balanced 3-phase
- Configuration: Radial topology, 6 buses
- Total length: 4 miles
- Total load: 150 MW, 75 MVAR
- Line parameters: R = 0.3 Ω/mile, X = 0.4 Ω/mile
- Base MVA: 10 MVA

**Regulation Devices:**
- Voltage regulator: Installed on line between Bus 2-3, tap ratio 0.95 (5% boost)
- Capacitor bank: 2.0 MVAR at Bus 5

## Results

**Voltage Improvements:**

| Bus | Base Case | With Regulator | Reg + Capacitor | Status |
|-----|-----------|----------------|-----------------|--------|
| 1   | 1.0000 pu | 1.0000 pu      | 1.0000 pu       | OK     |
| 2   | 0.9525 pu | 0.9537 pu      | 0.9593 pu       | OK     |
| 3   | 0.8855 pu | 0.9421 pu      | 0.9567 pu       | Violation |
| 4   | 0.8198 pu | 0.8817 pu      | 0.9072 pu       | Violation |
| 5   | 0.7752 pu | 0.8407 pu      | 0.8760 pu       | Violation |
| 6   | 0.7539 pu | 0.8212 pu      | 0.8573 pu       | Violation |

**System Losses:**
- Base case: 2.45 MW (1.6% of total load)
- Regulator only: 2.16 MW (1.4% of load, 12.1% reduction)
- Regulator + capacitor: 1.79 MW (1.2% of load, 27.0% reduction)

## Analysis

The voltage regulator provides significant voltage improvement by boosting downstream voltages approximately 6-7% at buses 3-6. The capacitor bank provides additional reactive power support locally at Bus 5, which reduces reactive current flow through all upstream lines. This reduced current flow decreases voltage drop across the entire feeder and significantly reduces I²R losses.

The capacitor's impact on loss reduction (27% total) exceeds its voltage improvement contribution, demonstrating that reactive power compensation provides system-wide benefits beyond the immediate connection point. The reduction in reactive current propagates upstream, improving voltage profile and reducing losses from Bus 1 through Bus 5.

While the combined solution brings buses 3-6 closer to acceptable limits, additional regulation equipment would be required to fully comply with ANSI C84.1 standards. The analysis demonstrates that voltage regulators and capacitor banks serve complementary functions in distribution system planning.

## Files

**feeder_base_case.m** - Defines the base feeder model with no regulation devices. Models 6 buses with loads totaling 150 MW and line impedances based on 0.3 Ω/mile resistance. This represents the problem scenario with voltage violations at buses 3-6.

**feeder_with_regulator.m** - Adds a voltage regulator on the line between Bus 2-3. The regulator is modeled as a transformer with tap ratio 0.95, providing approximately 5% voltage boost to downstream buses.

**feeder_with_regulator_and_cap.m** - Adds both voltage regulator and capacitor bank. The capacitor at Bus 5 provides 2.0 MVAR of reactive power, modeled as negative reactive load (Qd = -0.25 pu, accounting for 1.75 MVAR load demand and 2.0 MVAR capacitor injection).

**compare_all_cases.m** - Runs power flow analysis for all three scenarios, extracts voltage profiles and system losses, generates comparison plots, and displays results. Calculates real power losses using the correct formula: loss = sum(PF + PT) where PF is power at the "from" end and PT is power at the "to" end of each branch.

## Tools

- MATLAB/MATPOWER 8.0
- Newton-Raphson power flow solver
- Per-unit system normalized to 10 MVA base
- Balanced single-phase equivalent model

## How to Run

1. Install MATPOWER in MATLAB (run `install_matpower` after downloading)
2. Navigate to project directory
3. Run `compare_all_cases` in the MATLAB command window
4. Voltage comparison plot displays automatically
5. Results print to console showing voltage profiles and loss analysis

## Key Findings

The voltage regulator provides the primary voltage boost, improving Bus 6 voltage from 0.754 pu to 0.821 pu (8.9% improvement). Adding the capacitor bank provides additional improvement to 0.857 pu (13.7% total improvement from base case).

The capacitor bank's primary benefit is loss reduction rather than voltage support. By providing reactive power locally at Bus 5, it reduces reactive current flow through lines 1-2, 2-3, 3-4, and 4-5. This current reduction yields 27% total loss reduction compared to base case, with the capacitor alone contributing approximately 15% loss reduction beyond the regulator.

The heavily loaded feeder (150 MW over 4 miles) demonstrates realistic distribution planning challenges. In practice, utilities would supplement these devices with larger conductors, higher operating voltages, or load distribution across multiple feeders to fully meet voltage standards.