import numpy as np
import matplotlib.pyplot as plt

def display_2d(img, points_mm, slice_axis, slice_position, resolution):
    """
    Plots a 2D slice of the 3D volume.
    slice_axis: 0 for X, 1 for Y, 2 for Z
    """
    idx = np.abs(points_mm[:, slice_axis] - slice_position) < 1e-6
    slice_plane = points_mm[idx, :]
    c = img[idx]

    if len(c) == 0:
        print("No points found at slice position.")
        return

    # Assuming Z slice
    x = slice_plane[:, 0]
    y = slice_plane[:, 1]

    plt.scatter(x, y, c=c, cmap='jet', marker='s', s=50) # 's' for square markers to simulate pixels
    plt.colorbar()
    plt.xlabel("X (mm)")
    plt.ylabel("Y (mm)")
    plt.title(f"2D Slice at {slice_axis}={slice_position}mm")
    plt.axis('equal')

def display_3d(img, points_mm, antenna_locations_mm, threshold):
    """
    Plots a 3D scatter plot of the image intensities above a threshold.
    """
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')

    valid = img > threshold
    if not np.any(valid):
        print("No points above threshold.")
        return

    x = points_mm[valid, 0]
    y = points_mm[valid, 1]
    z = points_mm[valid, 2]
    c = img[valid]
    sizes = 100 * c

    sc = ax.scatter(x, y, z, c=c, cmap='jet', s=sizes, alpha=0.5)

    # Plot antennas
    ax.scatter(antenna_locations_mm[:, 0], antenna_locations_mm[:, 1], antenna_locations_mm[:, 2],
               c='black', marker='^', s=100, label='Antennas')

    plt.colorbar(sc, ax=ax)
    ax.set_xlabel("X (mm)")
    ax.set_ylabel("Y (mm)")
    ax.set_zlabel("Z (mm)")
    ax.set_title("3D Beamforming Reconstruction")
    ax.legend()
