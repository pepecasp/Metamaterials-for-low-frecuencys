# 🔊 Broadband Acoustic Metamaterial Parametric Design

This repository contains the mathematical and geometric models developed for the design of an acoustic metamaterial oriented towards low-frequency absorption (bass trap). The system consists of a graded panel of 36 coupled Helmholtz resonators, tuned to cover the modal range from **150 Hz to 250 Hz**.

This project is part of the Bachelor's Thesis (TFG) in **Sound and Image Engineering** at the **Universidad de Málaga**.

## 📊 1. Analytical Model (MATLAB)
The `/matlab` directory contains the scripts for calculating surface impedances and acoustic absorption. 
The design is based on a locally reactive surface topology, evaluating absorption for both normal incidence (Kundt's Tube) and diffuse field (Paris Formula / Sabine Coefficient).

*(Nota: Sube la imagen de Kundt vs Sabine a la carpeta raíz y cambia este texto por la ruta a la imagen, por ejemplo: `![Acoustic Absorption](graph.png)`)*

**Key results:** 
* Average absorption greater than $\alpha = 0.9$ in the target design range.
* Thermal and viscous efficiency maximized through geometric compliance tuning.

## 📐 2. 3D Parametric Model (OpenSCAD)
The `/3d_model` directory includes the OpenSCAD source code used to generate the physical geometry of the panel via boolean subtraction, as well as the files ready for manufacturing and integration into simulation software.

* **`full_panel.scad`**: Parametric script that generates the 6x6 cell matrix maintaining a constant footprint and adjusting the depth of the cavities based on the tuning vectors.
* **`print_panel.stl`**: Exported mesh with a flat back face, ready for slicing and 3D printing (FDM/SLA).
* **`fluid_domain.step`**: CAD solid that isolates the air volumes (cavities and necks), prepared for Finite Element Analysis (FEA/FEM) in multiphysics software (COMSOL, Ansys, or Elmer).

*(Nota: Añade aquí la imagen del renderizado a color transversal: `![3D Cross Section](3d_section.png)`)*

## 🛠️ How to use this repository
1. **Analytical calculation:** Run the main `.m` file in MATLAB to regenerate the depth vectors and absorption graphs.
2. **3D Generation:** Open the `.scad` file in [OpenSCAD](https://openscad.org/). Modify the initial variables (such as neck length or wall thickness) and press `F5` to preview, or `F6` to render a new geometry based on the new calculations.

---
**Author:** Pepe Castillo  
**Project:** TrueSound / Bachelor's Thesis
