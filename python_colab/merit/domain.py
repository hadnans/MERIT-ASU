import numpy as np

def hemisphere(radius, resolution=2.5e-3):
    """
    Creates a 3D grid of points in the shape of a hemisphere.
    """
    d = int(np.ceil(2 * radius / resolution))
    x = np.linspace(-radius, radius, d)
    y = np.linspace(-radius, radius, d)
    z = np.linspace(0, radius, d) # Hemisphere implies z >= 0

    X, Y, Z = np.meshgrid(x, y, z, indexing='ij')

    # Flatten the grid
    points = np.column_stack((X.ravel(), Y.ravel(), Z.ravel()))

    # Filter points to only those inside the radius
    distances = np.sqrt(points[:,0]**2 + points[:,1]**2 + points[:,2]**2)
    valid_idx = distances <= radius
    points = points[valid_idx]

    return points
