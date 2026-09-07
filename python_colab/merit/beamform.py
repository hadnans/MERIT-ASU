import numpy as np
from scipy.spatial.distance import cdist

def get_delays(channel_names, sensors_locations, relative_permittivity=1, extra_delay=0, points=None):
    """
    Computes theoretical time-of-flight delays.
    If points are provided, it returns delays per point.
    (Usually, mimt.process handles delay directly, but this mimics merit.beamform)
    """
    c0 = 299792458.0
    speed = c0 / np.sqrt(relative_permittivity)

    # 0-indexed in python
    tx_idx = channel_names[:, 0].astype(int) - 1
    rx_idx = channel_names[:, 1].astype(int) - 1

    tx_pos = sensors_locations[tx_idx, :]
    rx_pos = sensors_locations[rx_idx, :]

    if points is not None:
        dist_tx = cdist(tx_pos, points)
        dist_rx = cdist(rx_pos, points)
        delays = -extra_delay - (dist_tx + dist_rx) / speed
        return delays
    else:
        # If points not provided, return a function (closure) like MATLAB might
        def delay_func(pts):
            dist_tx = cdist(tx_pos, pts)
            dist_rx = cdist(rx_pos, pts)
            return -extra_delay - (dist_tx + dist_rx) / speed
        return delay_func
