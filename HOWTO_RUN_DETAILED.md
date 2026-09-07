# MERIT-ASU: Detailed Execution and Visualization Guide

This guide provides an in-depth walkthrough on how to execute the main operational scripts (`ain_shams/main.m` and `ain_shams/sweep.m`) and explains how to interpret the resulting 2D and 3D visualization graphs.

## 1. Running the System (`ain_shams/main.m`)

The `main.m` script is the primary entry point for configuring and running a single microwave imaging reconstruction.

### Data Options
- **`data`**:
  - `0`: Run using simulated data.
  - `1`: Run using measured (experimental) data.
  - `2`: Run using "all" round/cross dataset.
- **`conf_pol`**: Sets the antenna configuration and polarization (e.g., `11` for Linear-Linear, `22` for Circular-Circular).
- **`channels_mode`**:
  - `1`: Removes transmissions, keeping only reflections.
  - `2`: Removes reflections, keeping only transmissions.
  - `3`: Uses all available channels (both monostatic and multistatic).

### Imaging Domain Parameters
- **`ROI` (Region of Interest)**: The maximum radius of the breast phantom (e.g., `0.075` meters or 7.5 cm). The imaging grid is constrained to this hemisphere to save memory and computation.
- **`slice`**: The z-axis position (height) at which to extract and visualize the 2D cross-section (e.g., `0.03` meters).
- **`resolution`**: The distance between adjacent points in the 3D imaging grid (e.g., `2.5e-3` meters or 2.5 mm). *Warning: Decreasing this value drastically increases memory consumption and computational time.*
- **`relative_permittivity`**: The assumed dielectric constant of the breast tissue. This determines the signal propagation speed used in the beamformer.

### Processing Options
You can toggle different signal processing stages by setting them to `1` (enabled) or `0` (disabled):
- **`background_subtraction`**: Subtracts an "empty" scan from the "tumor" scan to eliminate static reflections (like the antennas themselves).
- **Clutter Removal (CR)**:
  - `time_gating_cr`: Mutes early/late signals outside the expected tumor response window.
  - `av_sub_cr`: Subtracts the average signal across all channels to remove the symmetric skin reflection.
  - `svd_cr`: Uses Singular Value Decomposition to remove the strongest, most coherent signals (typically skin).
- **Beamforming Options**:
  - `algorithm`: Set to `1` to use the advanced `mimt` beamformers.
  - `method`: Select the mathematical approach (`'DAS'`, `'DMAS'`, `'CF'`, `'MVDR'`, `'CAPON'`, or `'MUSIC'`).

## 2. Running a Parameter Sweep (`ain_shams/sweep.m`)

If you are unsure of the optimal configuration (such as the exact relative permittivity or the best frequency band), use `sweep.m`.

This script iterates over predefined arrays of values (e.g., `relative_permittivity_list`, `f_start_list`, `f_end_list`, `freq_step_list`, `threshold_list`). For each combination, it reconstructs the image, calculates the estimated tumor coordinates (`tumor_x`, `tumor_y`), and automatically saves the resulting 2D/3D plots to the `./ain_shams/results/sweep/` directory.

## 3. Interpreting the Visualizations

When the `compute_beamform.m` pipeline finishes, it generates a MATLAB figure containing two subplots:

### Subplot 1: 2D Cross-Section (`display_2d`)
This subplot displays a 2D horizontal slice of the 3D reconstructed volume at the height specified by the `slice` parameter.
- **Axes**: Represent the physical X and Y coordinates (in millimeters).
- **Colormap (`jet`)**: The colors represent the normalized intensity of the beamformer output. Deep blue indicates low intensity (no scatterer detected), while bright red indicates the highest intensity (the most likely location of the tumor).
- **Interpretation**: A successful reconstruction will show a concentrated, bright red "hotspot" at the physical location where the tumor resides.

### Subplot 2: 3D Volume Rendering (`display_3d`)
This subplot provides a volumetric view of the entire breast phantom.
- **Axes**: X, Y, and Z physical coordinates (in millimeters). The antennas are often plotted as markers around the periphery.
- **Transparency/Isosurface**: Instead of showing every point, the 3D plot typically renders isosurfaces or uses transparency (alpha mapping) to hide low-intensity regions.
- **Interpretation**: You will see a 3D "blob" floating in space, which represents the highest intensity region across all Z-slices. This helps confirm whether the tumor is isolated to a specific depth or if the reconstruction is suffering from vertical smearing (poor depth resolution). You can interactively rotate this plot in MATLAB to view the tumor from different angles.