import numpy as np
import pandas as pd
import os
import mimt.manage_data as md

def load_data_asu(data, conf_pol, channels_mode, data_dir='data'):
    """
    Mock/Simplified data loader for Python.
    It expects CSV files inside the `data_dir`.
    """
    try:
        scan1 = np.loadtxt(os.path.join(data_dir, 'scan1.csv'), delimiter=',')
        scan2 = np.loadtxt(os.path.join(data_dir, 'scan2.csv'), delimiter=',')

        frequencies = np.loadtxt(os.path.join(data_dir, 'frequencies.csv'), delimiter=',') * 1e9 # assume GHz in CSV
        if frequencies.ndim == 1:
            frequencies = frequencies[:, None]

        sensors_locations = np.loadtxt(os.path.join(data_dir, 'antenna_locations.csv'), delimiter=',') * 1e-3 # assume mm
        channel_names = np.loadtxt(os.path.join(data_dir, 'channel_names.csv'), delimiter=',')

        # In actual CSV output from VNA, it might be complex strings.
        # For this python port, we assume numeric formats are parsed, or we load Real and Imag separately.
        # Below we assume the matrix is already complex numbers if loaded successfully by numpy,
        # else users must preprocess their CSVs to float arrays.

        if channels_mode == 1:
            scan2, scan1, channel_names = md.remove_transmissions(scan2, scan1, channel_names)
        elif channels_mode == 2:
            scan2, scan1, channel_names = md.remove_reflections(scan2, scan1, channel_names)

        return scan2, scan1, frequencies, sensors_locations, channel_names
    except Exception as e:
        print(f"Error loading data: {e}")
        print("Please ensure scan1.csv, scan2.csv, frequencies.csv, channel_names.csv, and antenna_locations.csv exist in the data directory.")
        # Return dummies for testing
        return np.zeros((10,10)), np.zeros((10,10)), np.zeros((10,1)), np.zeros((10,3)), np.zeros((10,2))
