# PD_ORCA_TOP_28nm
Block-level multi-voltage ASIC physical design with 52K cells and 40 macros. Complete flow from floorplanning to timing signoff, including multi-power domains and 5 clocks. Includes TCL automation scripts for port placement, voltage area creation, timing fixes, PrimeTime DMSA setup, plus Unix and CMOS basics.

# Physical Design Block (28nm, Multi-Voltage)

## Project Overview
This project demonstrates block-level physical design at the 28nm technology node for a multi-voltage ASIC block with 52K standard cells and 40 macros. The design features two power domains and five clocks, covering the complete flow from floorplanning to timing signoff.

## Tools Used
- Synopsys ICC2 Compiler
- Synopsys Design Compiler
- Synopsys PrimeTime

## Key Steps
- Floorplanning
- Placement
- Clock Tree Synthesis (CTS)
- Routing
- Timing Analysis & Signoff

## Challenges
- **Voltage Area Planning:**  
  Efficiently allocating voltage areas for two power domains. Developed TCL scripts to calculate required area (with 20% margin), align voltage areas with site rows/columns, and avoid area shortages.
- **Congestion Management:**  
  Multiple macro placement iterations and fly-line analysis were done to reduce routing congestion and improve routability.
- **Logic Depth in I_BLENDER Family:**  
  High logic depth (~40) led to setup violations. Addressed with repeated place optimizations, timing analysis, and path grouping for critical paths.

## Results
- Achieved timing closure
- Met area and power targets for both power domains
- Automated key PD tasks using TCL scripts

## About Me
Fresher interested in VLSI physical design and automation.
