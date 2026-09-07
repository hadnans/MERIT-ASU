import numpy as np
from scipy.spatial.distance import cdist

def beamformer_freq_domain(data, freqs, channel_names, sensors_loc, grid_pts, method='DAS', eps_r=1.0, extra_delay=0.0, normalize=True, power=2):
    """
    Unified frequency-domain beamformer (3D).
    """
    Nf, Nc = data.shape
    Np = grid_pts.shape[0]
    freqs = freqs.flatten()
    two_pi_f = 2 * np.pi * freqs
    image_vec = np.zeros(Np)

    c0 = 299792458.0
    speed = c0 / np.sqrt(eps_r)

    # Python is 0-indexed
    tx_idx = channel_names[:, 0].astype(int) - 1
    rx_idx = channel_names[:, 1].astype(int) - 1

    tx_pos = sensors_loc[tx_idx, :]
    rx_pos = sensors_loc[rx_idx, :]

    # Calculate all distances (Warning: can be memory intensive for large grids)
    dist_tx = cdist(tx_pos, grid_pts)
    dist_rx = cdist(rx_pos, grid_pts)

    delays = -extra_delay - (dist_tx + dist_rx) / speed

    method = method.upper()

    # Vectorized phase alignment for ALL points at once
    # phase: (Nf, Nc, Np) - Can cause OOM for large Np, so we loop over chunks if necessary.
    # To be extremely efficient without OOM, we compute sig per point, but doing it in a fast numpy way.

    for pnt in range(Np):
        phase = np.exp(1j * two_pi_f[:, None] * delays[:, pnt])
        sig = np.sum(data * phase, axis=0) # shape (Nc,)

        if method == 'DAS':
            s = np.sum(sig)
        elif method == 'DMAS':
            s = 0.5 * (np.abs(np.sum(sig))**2 - np.sum(np.abs(sig)**2))
        elif method == 'CF':
            coherent = np.abs(np.sum(sig))
            incoherent = np.sum(np.abs(sig))
            cf = coherent / (incoherent + 1e-12)
            s = cf * np.sum(sig)
        elif method == 'MVDR' or method == 'CAPON':
            R = np.outer(sig, np.conj(sig)) / Nc + 1e-6 * np.eye(Nc)
            a = np.ones((Nc, 1))
            # using solve or lstsq
            R_inv_a = np.linalg.solve(R, a)
            if method == 'MVDR':
                w = R_inv_a / (a.T.conj() @ R_inv_a)
                s = w.T.conj() @ sig[:, None]
                s = s[0,0]
            else: # CAPON
                s = 1 / np.real(a.T.conj() @ R_inv_a)
                s = s[0,0]
        elif method == 'MUSIC':
            R = np.outer(sig, np.conj(sig)) / Nc
            # eigh is much faster and more stable for Hermitian matrices like Covariance matrices
            eigenvals, V = np.linalg.eigh(R)
            idx = np.argsort(eigenvals)[::-1]
            V = V[:, idx]
            En = V[:, 1:] # Noise subspace
            a = np.ones((Nc, 1))
            denom = np.linalg.norm(En.T.conj() @ a)**2
            s = 1 / (denom + 1e-12)

        image_vec[pnt] = np.abs(s)**power

    if normalize:
        m = np.max(image_vec)
        if m != 0:
            image_vec = image_vec / m

    return image_vec

def calculate_tumor_info(points, img, slice_z, tol, threshold_ratio):
    idx = np.abs(points[:, 2] - slice_z) < tol
    xy_slice = points[idx, :]
    xy_img = img[idx]

    if len(xy_slice) == 0:
        return 0, 0, 0

    max_idx = np.argmax(xy_img)
    x0, y0 = xy_slice[max_idx, 0], xy_slice[max_idx, 1]

    return x0 * 1e3, y0 * 1e3, 0 # simple return for X,Y in mm

def compute_beamform(params):
    import mimt.manage_data as md
    import mimt.clutter_removal as cr
    from merit.domain import hemisphere

    scan2 = params['scan2']
    scan1 = params['scan1']
    freqs = params['frequencies']

    scan2, scan1, freqs = md.adjust_freq_step(scan2, scan1, freqs, params['freq_step'])

    c_0 = 299792458.0
    v_feed = c_0 / np.sqrt(params['feed_permittivity'])
    extra_delay = (params['feed_d'] / v_feed) + (params['gap'] / c_0)

    # Frequency bounds
    valid_f = (freqs[:,0] >= params['f_start']) & (freqs[:,0] <= params['f_end'])
    freqs = freqs[valid_f]
    scan2 = scan2[valid_f, :]
    scan1 = scan1[valid_f, :]

    if params['background_subtraction'] == 1:
        signals = scan2 - scan1
    else:
        signals = scan2

    if params['av_sub_cr'] == 1:
        signals = cr.average_subtraction(signals)

    if params['svd_cr'] == 1:
        signals, _, _ = cr.tumor_svd(signals, np.mean(signals, axis=1, keepdims=True), 0.9)

    grid_pts = hemisphere(params['ROI'], resolution=params['resolution'])

    img = beamformer_freq_domain(
        signals, freqs, params['channel_names'], params['sensors_locations'], grid_pts,
        method=params['method'], eps_r=params['relative_permittivity'], extra_delay=extra_delay
    )

    tumor_x, tumor_y, _ = calculate_tumor_info(grid_pts, img, params['slice'], 1e-4, 0.6)

    return img, tumor_x, tumor_y, grid_pts
