# MERIT-ASU: Microwave Imaging Toolbox for Breast Cancer Detection

This repository contains the `MERIT-ASU` toolbox, an advanced software suite for Microwave Imaging (MWI), primarily focused on breast cancer detection. It is built upon the open-source MERIT (Microwave Radar-based Imaging Toolbox) and extensively customized with additional modules tailored for Ain Shams University (ASU).

## 🏗️ Architecture and Directory Structure

The codebase is logically divided into three primary namespaces/directories:

1. **`+merit`**:
   - Contains the core, foundational functionalities of the original MERIT toolbox.
   - Handles spatial domain creation (`hemisphere`, `img2grid`), time-frequency transformations (`fd2td`, `td2fd`), basic delay computations, and general beamforming logic.
2. **`+mimt` (Microwave Imaging Medical Toolbox)**:
   - Contains advanced, customized processing pipelines introduced for ASU.
   - **`+clutter_removal`**: Advanced signal processing algorithms (SVD, adaptive filtering, average subtraction, time gating) to suppress dominant skin reflections and isolate weak tumor scattering.
   - **`+manage_data`**: Utilities for preprocessing data (scaling, rotating, filtering transmissions vs reflections).
   - **`+process`**: The core execution pipeline (`compute_beamform.m`) and frequency-domain beamforming algorithms (`beamformer_freq_domain.m` supporting DAS, DMAS, CF, MVDR, CAPON, MUSIC).
3. **`ain_shams`**:
   - The user-facing operational scripts.
   - **`main.m`**: The primary script to configure parameters, load a specific dataset (simulated or measured), and generate a 2D/3D image of the target region.
   - **`sweep.m`**: A parameter sweep script useful for tuning values like relative permittivity and frequency bands over large datasets.
   - **`tools`**: Dataset loaders specific to the ASU data structure.

## 🚀 How to Use

To generate a microwave image:

1. Open MATLAB and navigate to the root directory of this repository.
2. Open `ain_shams/main.m`.
3. Configure the **Data Options** block:
   - `data`: Choose `0` for simulation, `1` for measured, `2` for all.
   - `conf_pol`: Configuration polarizations (e.g., `11`, `12`, `21`, `22`).
   - `channels_mode`: `1`, `2`, or `3` to select monostatic/multistatic configurations.
4. Configure the **Processing Options** block:
   - Choose which clutter removal algorithms to enable (`time_gating_cr`, `av_sub_cr`, `svd_cr`, etc.) by setting them to `1` or `0`.
   - Set your beamforming `algorithm` (`0` for merit, `1` for mimt) and `method` (e.g., `'DAS'`, `'DMAS'`, `'MUSIC'`).
5. Run `main.m`. The script will output the estimated tumor location and plot the 2D slice and 3D volume showing the beamforming intensity.

To run a parameter sweep, open and configure `ain_shams/sweep.m` with your desired parameter ranges (`relative_permittivity_list`, `f_start_list`, etc.) and run it.

## 🔬 Physical Concepts

Microwave imaging relies on the **dielectric contrast** between different tissues. Malignant breast tumors typically have a higher water content than healthy fatty tissue, resulting in a significantly higher relative permittivity and conductivity.

1. **Backscattering & Propagation**:
   - Antennas transmit microwave pulses into the breast.
   - When the wave encounters a boundary between tissues of different dielectric properties, part of the signal scatters back.
   - By calculating the expected **propagation delay** (time taken for a wave to travel from the transmitter, to a specific spatial point, and back to the receiver), we can align the received signals.
2. **Clutter Removal**:
   - The strongest reflection comes from the skin-air or skin-matching liquid interface. This "clutter" masks the weak tumor response.
   - Algorithms like **SVD (Singular Value Decomposition)** decompose the signals to isolate and remove the strongest coherent reflections, leaving behind the tumor signal.
3. **Beamforming Algorithms**:
   - Beamformers act as synthetic lenses. They artificially delay the signals from all antenna pairs and sum them up for every point in a 3D grid.
   - **DAS (Delay and Sum)**: The simplest approach; signals add constructively at the location of the scatterer.
   - **DMAS (Delay Multiply and Sum)**: Multiplies signal pairs before summing, improving contrast and resolution by increasing spatial coherence.
   - **MUSIC / MVDR**: High-resolution, adaptive subspace methods that calculate spatial covariance to pinpoint scatterers with sub-wavelength precision.

## ⚡ How to Enhance Performance

This codebase performs heavy matrix computations. To optimize speed and handle larger datasets, consider the following performance enhancements:

1. **Parallel Computing (`parfor`)**:
   - In `+mimt/+process/beamformer_freq_domain.m`, the main loop iterates over every point in the spatial grid (`for pnt = 1:Np`). Since the calculation for each point is independent, changing this to a `parfor` loop will drastically reduce computation time using multi-core processors.
2. **Vectorization**:
   - Algorithms like **DMAS** use nested `for` loops to multiply signal pairs. This can be vectorized using matrix operations or cross-correlation formulations, completely eliminating the inner loops.
3. **GPU Acceleration (`gpuArray`)**:
   - Move large variables (like `sig`, `phase`, and spatial coordinates) to the GPU using `gpuArray()`. Matrix inversions in **MVDR** and **CAPON**, and eigenvalue decompositions in **MUSIC** benefit significantly from GPU parallelization.
4. **Pre-computing Propagation Delays**:
   - In parameter sweeps (`sweep.m`), if the physical domain and antenna locations do not change, propagation delays can be computed once outside the loop instead of being recalculated in every iteration.
5. **Memory Management**:
   - The `pdist2` function used to compute distances can consume massive amounts of memory for fine resolutions. Breaking the points into chunks/batches allows for high-resolution imaging without triggering out-of-memory errors.