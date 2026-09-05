# MERIT-ASU: Data Management and Functions Guide

This guide provides a thorough explanation of where to place your own experimental or simulated datasets, the expected file formats, and a detailed reference of the most commonly used functions in the `MERIT-ASU` toolbox so you can easily build your own custom processing scripts.

## 1. Where to Put Your Files and the Expected Formats

The software loads datasets primarily through the `ain_shams/tools/load_data_asu.m` script. To ensure your custom data is loaded correctly, you should place it in the `ain_shams/data/` directory.

### Directory Structure Example
```
ain_shams/
└── data/
    └── my_new_experiment/
        ├── scan1.csv             (Empty system scan / Baseline)
        ├── scan2.csv             (Scan with tumor / Object)
        ├── frequencies.csv       (List of frequencies used)
        ├── channel_names.csv     (Tx and Rx antenna pairs)
        └── antenna_locations.csv (Physical 3D coordinates of antennas)
```

### File Formats
1. **`scan1.csv` and `scan2.csv`**: These contain the S-parameter data.
   - Rows: Number of frequency points.
   - Columns: Number of antenna channels (pairs).
   - Values: Complex numbers (often represented as Real and Imaginary parts, or Magnitude and Phase, converted into complex arrays before processing).
2. **`frequencies.csv`**:
   - A single column listing the frequencies (in Hertz or GHz, depending on how you scale it when loading) used in the VNA sweep.
3. **`channel_names.csv`**:
   - An `N x 2` matrix.
   - Column 1: Transmitting antenna index (Tx).
   - Column 2: Receiving antenna index (Rx).
   - Example row `[1, 5]` means Antenna 1 transmitted and Antenna 5 received.
4. **`antenna_locations.csv`**:
   - An `M x 3` matrix representing the 3D coordinates (X, Y, Z) in meters or millimeters.
   - Rows represent the antenna index (Row 1 = Antenna 1, etc.).

### Modifying the Loader
To load your custom data without breaking existing code, you can either:
- Open `ain_shams/tools/load_data_asu.m` and add an `elseif data == 3` block pointing to your specific files.
- **Or** bypass the loader entirely in a custom script by simply using `readmatrix('path/to/my/scan.csv')`.

---

## 2. Using the Core Functions Easily

If you wish to bypass `main.m` and write your own custom script, you will need to utilize the functions inside the `+mimt` (Microwave Imaging Medical Toolbox) directory. Here is a breakdown of how to use them.

### Data Management (`+mimt/+manage_data`)
These functions clean and prepare the raw data matrix.

- **`remove_reflections(scan2, scan1, channel_names)`**:
  - **Purpose**: Removes monostatic channels (where Tx == Rx, e.g., $S_{11}$).
  - **Usage**: Use this if you only want to process the signals that traveled *through* the breast to a different antenna.
- **`remove_transmissions(scan2, scan1, channel_names)`**:
  - **Purpose**: Removes multistatic channels (where Tx $\neq$ Rx).
  - **Usage**: Use this if you only want to process self-reflections.
- **`scale_reflections(scan, channel_names, scale_factor)`**:
  - **Purpose**: Artificially scales down/up the monostatic reflections relative to transmissions, which can help balance the dynamic range.

### Clutter Removal (`+mimt/+clutter_removal`)
These functions are critical for exposing the weak tumor signal hidden beneath massive skin reflections. They are applied to the subtracted signal (`signals = scan2 - scan1`).

- **`average_subtraction(signals)`**:
  - **Purpose**: The simplest clutter removal. It assumes skin reflections are identical across all channels and subtracts the mean signal.
  - **Usage**: `signals_clean = mimt.clutter_removal.average_subtraction(signals);`
- **`tumor_svd(signals, mean_sig, threshold)`**:
  - **Purpose**: Decomposes the signal matrix to isolate dominant eigenvectors (skin) and remove them.
  - **Usage**: `[clean_sig, ~, ~] = mimt.clutter_removal.tumor_svd(signals, mean(signals,2), 0.9);`
- **`time_gating(signals, start_index)`**:
  - **Purpose**: Mutes all time-domain data before a specific index to ignore early-arriving skin reflections. *Note: Requires `signals` to be converted to the time domain first using `merit.process.fd2td`.*

### Beamforming (`+mimt/+process/beamformer_freq_domain.m`)
This is the heavy lifter. It takes the clean signals and creates the 3D intensity map.

**Usage Example:**
```matlab
% Define the 3D grid points (e.g., a hemisphere with 2.5mm resolution)
[grid_pts, ~] = merit.domain.hemisphere(0.075, 'resolution', 2.5e-3);

% Run the beamformer
img_vec = mimt.process.beamformer_freq_domain(...
    signals, ...               % The clean NxM complex data matrix
    frequencies, ...           % Nx1 array of frequencies in Hz
    channel_names, ...         % Mx2 array of Tx/Rx pairs
    sensors_locations, ...     % Kx3 array of physical antenna coords
    grid_pts, ...              % Px3 array of imaging target coordinates
    'relative_permittivity', 8, ...  % Assumed dielectric constant of tissue
    'method', 'DMAS', ...      % Choose 'DAS', 'DMAS', 'MVDR', 'CAPON', 'MUSIC'
    'normalize', true);        % Scales output between 0 and 1
```

### Visualization (`+mimt/+visualization`)
Once you have `img_vec` from the beamformer, you need to display it.

- **`display_2d(img, points_mm, axis, slice_mm, resolution)`**:
  - **Usage**: Plots a flat slice. `axis = 3` slices along the Z-axis.
  - `mimt.visualization.display_2d(img_vec, grid_pts*1e3, 3, 30, 2.5);`
- **`display_3d(img, points_mm, sensors_locations_mm, threshold)`**:
  - **Usage**: Renders a 3D volume, hiding points below the threshold (e.g., `0.8` means only show the top 20% highest intensities).
  - `mimt.visualization.display_3d(img_vec, grid_pts*1e3, sensors_locations*1e3, 0.8);`