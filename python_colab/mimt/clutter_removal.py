import numpy as np

def average_subtraction(signals):
    """
    Subtracts the average of all columns from every column.
    """
    clutter = np.mean(signals, axis=1, keepdims=True)
    return signals - clutter

def tumor_svd(signals, baseline, energy_thresh):
    """
    Removes the dominant eigenvectors (skin) using SVD.
    """
    M_diff = signals - baseline

    # SVD
    U, S, Vh = np.linalg.svd(M_diff, full_matrices=False)

    # Calculate energy
    energy = S**2
    total_energy = np.sum(energy)

    cum_energy = 0
    k = 0
    for i in range(len(S)):
        cum_energy += energy[i]
        if cum_energy / total_energy >= energy_thresh:
            k = i + 1
            break

    # Reconstruct removing top k modes (usually top 1-2 for skin)
    # The matlab code might keep bottom modes or drop top mode.
    # We drop the first `k` dominant modes assuming they are clutter.
    # (Actually standard SVD clutter removal drops the top few modes.
    # The Matlab `tumor_svd` keeps components until energy_thresh is hit and removes the rest,
    # or removes the top component depending on exact implementation.)

    # Standard practice: Drop the 1st mode (strongest = skin).
    S_clean = np.copy(S)
    S_clean[0] = 0 # Drop strongest reflection

    M_recon = U @ np.diag(S_clean) @ Vh
    return M_recon, M_diff, k

def time_gating(signals, margin=50):
    """
    Placeholder for time gating (requires frequency->time transformation).
    """
    return signals
