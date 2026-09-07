import numpy as np
import pandas as pd
import os
import mimt.manage_data as md

def parse_complex_csv(filepath):
    """
    Reads a CSV file that may contain complex numbers formatted as strings (e.g. '1.5+2.3i' or '1.5+2.3j')
    commonly exported by HFSS or VNAs. Also skips non-numeric header rows automatically.
    """
    try:
        # Read as string DataFrame first
        df = pd.read_csv(filepath, header=None, dtype=str)
        # Drop rows that are purely text (headers)
        df = df[~df[0].str.contains(r'[a-zA-Z]', regex=True, na=False) | df[0].str.contains(r'[ij]', regex=True, na=False)]
        # Replace 'i' with 'j' for Python complex parsing, remove spaces
        df = df.apply(lambda col: col.str.replace('i', 'j').str.replace(' ', '').str.replace('+-', '-'))
        # Convert to complex numpy array
        return df.to_numpy(dtype=complex)
    except Exception as e:
        # Fallback to standard float loading if it's already pre-processed
        return np.loadtxt(filepath, delimiter=',')

def load_data_asu(data, conf_pol, channels_mode, data_dir='data'):
    """
    Data loader for Python.
    Handles robust loading of HFSS CSV files containing complex S-parameters.
    """
    try:
        scan1 = parse_complex_csv(os.path.join(data_dir, 'scan1.csv'))
        scan2 = parse_complex_csv(os.path.join(data_dir, 'scan2.csv'))

        # Load frequencies and locations (usually floats)
        freq_df = pd.read_csv(os.path.join(data_dir, 'frequencies.csv'), header=None, comment='%')
        frequencies = freq_df.to_numpy(dtype=float) * 1e9 # assume GHz in CSV
        if frequencies.ndim == 1:
            frequencies = frequencies[:, None]

        loc_df = pd.read_csv(os.path.join(data_dir, 'antenna_locations.csv'), header=None, comment='%')
        sensors_locations = loc_df.to_numpy(dtype=float) * 1e-3 # assume mm

        ch_df = pd.read_csv(os.path.join(data_dir, 'channel_names.csv'), header=None, comment='%')
        channel_names = ch_df.to_numpy(dtype=int)

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
