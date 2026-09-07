# MERIT-ASU Python Port for Google Colab

This directory contains a complete Python translation of the MATLAB MERIT-ASU microwave imaging codebase. It is designed specifically so you can upload it to Google Colab and execute intensive 3D beamforming algorithms using Google's powerful cloud CPUs and GPUs (if modified to use CuPy), completely bypassing the hardware limitations of a slow laptop.

## Architecture

The architecture mirrors the MATLAB codebase perfectly so you can transition between them:
- `merit/`: Core physical domain modeling (`domain.py`) and signal delays (`beamform.py`).
- `mimt/`: Advanced clutter removal (`clutter_removal.py`), data scaling/manipulation (`manage_data.py`), execution pipeline and beamforming algorithms (`process.py`), and visualization mapping (`visualization.py`).
- `ain_shams/`: User execution scripts.
  - `tools/load_data_asu.py`: Reads the raw CSV inputs.
  - `main.py`: The main execution script.

## How to use on Google Colab

1. **Zip the `python_colab` folder** on your computer.
2. Go to [Google Colab](https://colab.research.google.com/) and create a new Notebook.
3. Click the **Folder icon** on the left sidebar to open the File Explorer.
4. Upload your `python_colab.zip` file.
5. In a Colab cell, run `!unzip python_colab.zip` to extract it.

## Where to Put Your Data

You must place your 5 required CSV files inside the `python_colab/ain_shams/data/` folder before running the script. You can upload them directly via the Colab File Explorer or zip them with your code.

The required files are:
1. `scan1.csv`: The baseline background scan (NxM matrix).
2. `scan2.csv`: The scan with the tumor/object (NxM matrix).
3. `frequencies.csv`: A single column of frequency points (in GHz).
4. `channel_names.csv`: Two columns (Tx and Rx antenna indices).
5. `antenna_locations.csv`: Three columns (X, Y, Z physical coordinates in mm).

*Ensure that your S-Parameter CSV files are loaded correctly as complex numbers or float values, depending on your VNA's export settings.*

## Running the Code

Once the files are in place, you can execute the entire pipeline inside Colab using:

```python
!python python_colab/ain_shams/main.py
```

Alternatively, you can open the provided `Colab_Notebook.ipynb` directly in Google Colab, mount your Google Drive (so you don't have to upload CSV files every time), and run the cells interactively to see the 2D and 3D Matplotlib plots printed directly into your browser!