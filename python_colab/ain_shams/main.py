import sys
import os
import matplotlib.pyplot as plt

# Add the parent directory to Python path so modules resolve
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from ain_shams.tools.load_data_asu import load_data_asu
from mimt.process import compute_beamform
from mimt.visualization import display_2d, display_3d
import mimt.manage_data as md

# -------------------------------
# Configuration
# -------------------------------
params = {}
params['ROI'] = 0.075
params['slice'] = 0.03
params['resolution'] = 2.5e-3
params['relative_permittivity'] = 1.0

params['background_subtraction'] = 1
params['av_sub_cr'] = 1
params['svd_cr'] = 0
params['method'] = 'DAS'

params['feed_permittivity'] = 1.0
params['feed_d'] = 15e-3
params['gap'] = 2e-3

params['f_start'] = 1e9
params['f_end'] = 4e9
params['freq_step'] = 1

data = 0
conf_pol = 12
channels_mode = 3
scale_factor = -40

# Load data
scan2, scan1, freqs, sensors_loc, ch_names = load_data_asu(data, conf_pol, channels_mode, data_dir='data')
scan2 = md.scale_reflections(scan2, ch_names, scale_factor)
scan1 = md.scale_reflections(scan1, ch_names, scale_factor)

params['scan2'] = scan2
params['scan1'] = scan1
params['frequencies'] = freqs
params['sensors_locations'] = sensors_loc
params['channel_names'] = ch_names

# If dummy data was loaded (no real CSVs exist in the dir), we shouldn't run compute
if len(scan2) > 0 and not (scan2 == 0).all():
    # Compute Beamform
    img, tumor_x, tumor_y, grid_pts = compute_beamform(params)

    print(f"Estimated Tumor Location: X={tumor_x:.2f}mm, Y={tumor_y:.2f}mm")

    # Plot
    plt.figure(figsize=(12, 6))

    plt.subplot(1, 2, 1)
    display_2d(img, grid_pts * 1e3, 2, params['slice'] * 1e3, params['resolution'])

    # 3D plot requires a separate window/figure in standard matplotlib easily, or complex subplot config
    display_3d(img, grid_pts * 1e3, sensors_loc * 1e3, 0.8)

    plt.show()
else:
    print("Dummy data loaded. Place actual CSV files in `ain_shams/data` to run the reconstruction.")
