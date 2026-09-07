import numpy as np

def adjust_freq_step(scan2, scan1, frequencies, step):
    n = np.arange(0, len(frequencies), step)
    return scan2[n, :], scan1[n, :], frequencies[n]

def remove_reflections(scan2, scan1, channel_names):
    n = channel_names[:, 0] != channel_names[:, 1]
    return scan2[:, n], scan1[:, n], channel_names[n, :]

def remove_transmissions(scan2, scan1, channel_names):
    n = channel_names[:, 0] == channel_names[:, 1]
    return scan2[:, n], scan1[:, n], channel_names[n, :]

def scale_reflections(signals, channel_names, scale_db):
    signals_scaled = signals.copy()
    n = channel_names[:, 0] == channel_names[:, 1]
    # scale_db to linear magnitude: 10^(scale_db / 20)
    signals_scaled[:, n] = signals[:, n] * (10 ** (scale_db / 20.0))
    return signals_scaled

def rotate_data_set(scan2, A, channel_names):
    # Simplistic placeholder. Real translation requires complex matrix indexing
    # matching the original MATLAB `rotate_data_set.m` which shifts columns.
    return scan2
