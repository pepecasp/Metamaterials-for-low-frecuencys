# 🔊 Broadband Acoustic Metamaterial Parametric Design

This repository contains the mathematical, numerical and geometric models developed for the design of an acoustic metamaterial oriented towards low-frequency absorption (bass trap). The system consists of a graded panel of 36 Helmholtz resonators, tuned to cover the modal range from **150 Hz to 250 Hz**.

This project is part of the Bachelor's Thesis (TFG) in **Sound and Image Engineering** at the **Universidad de Málaga**.

## 📊 1. Analytical Model (MATLAB)
The `/matlab` directory contains the scripts for calculating surface impedances, transmission loss and acoustic absorption.

The work includes **two simulations**:

### 1.1 Simulation A: Duct with resonators
A duct loaded with an array of Helmholtz resonators, evaluated with the Transfer Matrix Method. As illustrated below, increasing the number of resonators (N) significantly boosts the Transmission Loss (TL) around the target tuning frequency.

![Transmission Loss - N Resonators](matlab/tl_comparison_n_resonators.png)

### 1.2 Simulation B: Graded cell panel
A 6x6 panel of resonator cells, each tuned to a different frequency within 150–250 Hz. The design is based on a locally reactive surface topology, evaluating absorption for both normal incidence (Kundt's Tube) and diffuse field (Paris Formula / Sabine Coefficient).

![Cell panel simulation](matlab/panel_absorption_36_fields.png)

**Key results (analytical model):**
* Average absorption greater than $\alpha = 0.9$ in the target design range.

## 🧪 2. Numerical Validation (COMSOL Multiphysics)
The graded panel was simulated in COMSOL Multiphysics to obtain its absorption coefficient and validate the analytical model of Section 1.2.

* **Model setup:** see [`panel_absorption.mph`](COMSOL/) — <physics interface, boundary conditions, mesh, frequency range>.
* **Exported data:** [`data/<data_panel>.txt`](COMSOL/) — absorption coefficient vs. frequency.


![Analytical vs COMSOL absorption](matlab/Analítico_vs_COMSO.png)

**Results:** <1–3 lines: agreement in peak positions/bandwidth, differences in amplitude, possible causes (e.g. losses model, end corrections, boundary conditions)>.

## 📐 3. 3D Model (OpenSCAD)
The `/openSCAD` directory includes the geometry of the 36-cell panel (6x6 matrix, constant footprint, cavity depth adjusted according to the tuning vectors).

* **`resonator_36fields.stl`**: Full panel mesh.
* **`resonador_36fields_transversal.stl`**: Cross-section of the panel, showing the cavities and necks.

![Cross section of the 36-cell panel](openSCAD/cross_section.png)

[View interactive 3D model (STL)](openSCAD/resonador_36fields_transversal.stl)

## 🛠️ 4. How to use this repository
1. **Simulation A (duct with resonators):** run `matlab/helmholtz_panel_tl.m` to compute the Transmission Loss for different numbers of resonators (N) and regenerate `tl_comparison_n_resonators.png`.
2. **Simulation B (cell panel):** run `matlab/helmholtz_panel_absorption.m` to compute the surface impedance and absorption of the graded panel.
3. **Analytical vs COMSOL comparison:** with the `.txt` file in `matlab/`, run `matlab/helmholtz_panel_absorption.m`.
4. **3D visualization:** open the `.stl` files in any mesh viewer or slicer.

**Requirements:** MATLAB <R2025a>; COMSOL Multiphysics <5.5> with the <Acoustics Module> (only needed to reopen the `.mph`).

---
**Author:** Pepe Castillo
**Project:** Bachelor's Thesis / Sound and Image Engineering
