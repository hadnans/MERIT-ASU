# MERIT-ASU: File-by-File Architecture Guide

This document breaks down the repository file by file. It explains the exact purpose of every significant MATLAB script (`.m` file) so that you can navigate, understand, and modify the underlying codebase with confidence.

---

## 1. The `ain_shams` Directory

This is the primary user-facing folder where execution begins.

### Root Scripts
- **`main.m`**: The main execution script. It loads data, defines the region of interest (ROI), sets processing options, calls the beamformer pipeline, and plots the final 2D and 3D images.
- **`sweep.m`**: A parameter sweep script. Instead of generating one image, it iterates over arrays of variables (like frequency ranges and permittivities), reconstructs the image for each combination, and saves the output plots to disk.

### `ain_shams/tools`
- **`load_data_asu.m`**: The central data loader. It interprets the `data`, `conf_pol`, and `channels_mode` flags from `main.m` to load the appropriate simulated, measured, or comprehensive dataset, then scales and filters the channels.

### `ain_shams/tools/stand_alone_files`
Contains various isolated utility scripts often used for data preparation outside the main pipeline.
- **`compute_antenna_locations_simulation.m`**: Calculates the theoretical 3D locations of antennas based on angle and height for simulated environments.
- **`evaluate_sensors_locations.m`**: Hardcodes or geometrically evaluates sensor positions for the physical measurement setup.
- **`prepare_measured_data.m`**: A script to parse raw measured `.csv` data from VNAs and format it.
- **`read_s2p_files.m`**: Parses Touchstone `.s2p` files (standard VNA output) into a complex matrix.
- **`read_scan_files.m`**: Utility to read standard CSV scan files into MATLAB matrices.

---

## 2. The `+mimt` Directory (Microwave Imaging Medical Toolbox)

This folder contains the advanced processing modules explicitly developed and added by ASU to handle clutter removal, data management, and frequency-domain beamforming.

### `+mimt/+clutter_removal`
Algorithms designed to remove the massive skin/interface reflections so the weak tumor signal becomes visible.
- **`adaptive_filter.m`**: Uses a reference channel and an LMS (Least Mean Squares) or RLS approach to adaptively subtract the skin reflection from other channels.
- **`average_subtraction.m`**: Computes the mean signal across all channels and subtracts it from every channel. Very fast, works well for highly symmetric setups.
- **`differential.m`**: Subtracts a circularly shifted version of the signal matrix from itself to remove common-mode background noise.
- **`time_gating.m`**: Identifies the peak of the signal (usually the skin) and mutes the signal outside a specific time window, focusing only on the expected time-of-flight depth of the tumor.
- **`tumor_svd.m`**: Performs Singular Value Decomposition on the data matrix, identifies the dominant eigenvectors (which represent the skin), and reconstructs the signal without them.

### `+mimt/+manage_data`
Pre-processing utilities that filter or alter the data matrix before clutter removal.
- **`adjust_freq_step.m`**: Downsamples the frequency array (e.g., taking every 2nd or 3rd frequency point) to speed up execution.
- **`remove_antenna_9.m`**: A specific hardware utility that drops data involving antenna 9.
- **`remove_consecutive_pairs.m`**: Removes data from antennas that are physically adjacent, as their mutual coupling often overwhelms the signal.
- **`remove_reflections.m`**: Filters out $S_{11}, S_{22}$, etc. Keeps only transmitted (multistatic) signals.
- **`remove_reversed_pairs.m`**: Since $S_{21}$ and $S_{12}$ are identical in reciprocal systems, this removes the redundant pairs to save computation time.
- **`remove_transmissions.m`**: Filters out all transmitted signals, keeping only the monostatic reflections ($S_{11}$).
- **`rotate_data_set.m`**: Synthetically rotates the data to emulate a rotating antenna array setup.
- **`scale_reflections.m`**: Multiplies the monostatic channels by a specific scaling factor (in dB) to balance their magnitude against transmitted channels.

### `+mimt/+process`
The core computational engines that connect the data to the final image.
- **`compute_beamform.m`**: The master pipeline function. It receives `params` from `main.m`, calculates delays, routes the signal through clutter removal, switches between time/frequency domains, calls the beamformer, and returns the 3D image.
- **`beamformer_freq_domain.m`**: The mathematical core. It loops through every spatial voxel and implements various beamforming formulas: Delay-and-Sum (DAS), Delay-Multiply-and-Sum (DMAS), Coherence Factor (CF), Capon, MVDR, and MUSIC.
- **`calculate_tumor_info.m`**: Analyzes the final 3D image matrix, finds the peak intensity (the assumed tumor), and calculates its physical X/Y coordinates and estimated radius based on a threshold.

### `+mimt/+visualization`
Plotting utilities.
- **`display_2d.m`**: Takes the 3D image volume and extracts a 2D slice (usually along the Z-axis) to display as a color-mapped heatmap using the `jet` colormap.
- **`display_3d.m`**: Creates a 3D scatter plot of the image volume, utilizing transparency (alpha) and size scaling to render the high-intensity regions as a floating 3D blob, alongside plotting the antenna locations.
- **`visualize_data.m`**: A debugging script to plot the raw frequency-domain magnitudes of the signals before processing.

---

## 3. The `+merit` Directory

This contains the foundation of the open-source Microwave Radar-based Imaging Toolbox. ASU utilizes these core functions to handle physics and domain modeling.

### `+merit/+beamform` & `+merit/+beamformers`
- **`get_delays.m`**: Calculates the theoretical time-of-flight (propagation delay) from antennas to spatial points based on distances and the assumed relative permittivity.
- **`imaging_domain.m`**: Converts physical boundaries into a list of points.
- **`DAS.m` / `DMAS.m` / `CDAS.m`**: The original MERIT implementations of these beamforming algorithms (ASU generally overrides these with `beamformer_freq_domain.m`).
- **`beamform.m`**: The original MERIT pipeline orchestrator.

### `+merit/+domain`
- **`create_circumference.m`**: Generates a circular array of antenna coordinates.
- **`hemisphere.m`**: Defines a 3D grid of points in the shape of a hemisphere (representing the breast), controlled by a specific resolution.
- **`img2grid.m`**: Maps a flat 1D array of intensities back into a 3D physical grid for visualization.

### `+merit/+process`
- **`fd2td.m`**: Converts Frequency Domain data to Time Domain data using Inverse Fast Fourier Transforms (IFFT) or Chirp Z-Transforms.
- **`td2fd.m`**: Converts Time Domain data back to the Frequency Domain.
- **`delay.m`**: Physically shifts a time-domain signal by a specific number of indices to align it for beamforming.