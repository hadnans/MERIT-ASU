function image_vec = beamformer_freq_domain(data, freqs, channel_names, sensors_loc, grid_pts, varargin)
% BEAMFORMER_FREQ_DOMAIN  Unified frequency-domain beamformer (3D)
%
% Supports: DAS, DMAS, CF, MVDR, CAPON, MUSIC
%
% Example:
%   image = beamformer_freq_domain(data, freqs, ch_names, sens_loc, grid_pts, 'method', 'MUSIC');
%
% AbdElrahman Mohamed Mahmoud
% ---------------------------
% Parse inputs
p = inputParser;
addRequired(p,'data');
addRequired(p,'freqs');
addRequired(p,'channel_names');
addRequired(p,'sensors_loc');
addRequired(p,'grid_pts');
addParameter(p,'method','DAS',@(x)ischar(x) && ismember(upper(x),{'DAS','DMAS','CF','MVDR','CAPON','MUSIC'}));
addParameter(p,'relative_permittivity',1,@(x) isnumeric(x)&&isscalar(x)&&x>=1);
addParameter(p,'extra_delay',0,@(x) isnumeric(x)&&isscalar(x));
addParameter(p,'normalize',true,@islogical);
addParameter(p,'power',2,@(x)isnumeric(x)&&isscalar(x));
parse(p,data,freqs,channel_names,sensors_loc,grid_pts,varargin{:});

method = upper(p.Results.method);
eps_r = p.Results.relative_permittivity;
extra_delay = p.Results.extra_delay;
doNorm = p.Results.normalize;
powerExp = p.Results.power;

% ---------------------------
% Validate & initialize
[Nf,Nc] = size(data);
Np = size(grid_pts,1);
freqs = freqs(:);
two_pi_f = 2*pi*freqs;
image_vec = zeros(Np,1);

if numel(freqs) ~= Nf
    error('Length of freqs must match number of rows in data (Nf).');
end
if size(channel_names,1) ~= Nc || size(channel_names,2) ~= 2
    error('channel_names must be Nc x 2.');
end

% ---------------------------
% Compute propagation delays
% PHYSICAL CONCEPT: Electromagnetic waves travel at the speed of light in vacuum (c0),
% but this speed is reduced when traveling through a dielectric medium (like breast tissue
% or matching liquid) characterized by its relative permittivity (eps_r).
c0 = 299792458;
speed = c0 / sqrt(eps_r);
tx_idx = channel_names(:,1);
rx_idx = channel_names(:,2);
tx_pos = sensors_loc(tx_idx,:);
rx_pos = sensors_loc(rx_idx,:);

% PERFORMANCE ENHANCEMENT: pdist2 can be very memory intensive for large grid_pts.
% Consider batching the grid points if you encounter Out Of Memory (OOM) errors.
dist_tx = pdist2(tx_pos, grid_pts);
dist_rx = pdist2(rx_pos, grid_pts);
% Negative for back-propagation
% PHYSICAL CONCEPT: Delay is computed as distance/speed. We use negative delays
% to synthetically back-propagate the received signals to the hypothetical scatterer location.
delays = -extra_delay - (dist_tx + dist_rx) / speed;

% ---------------------------
% Main loop over pixels
% PERFORMANCE ENHANCEMENT: Since the computation for each spatial point (pixel/voxel)
% is independent, this loop is highly suitable for parallelization.
% Change 'for pnt = 1:Np' to 'parfor pnt = 1:Np' to utilize multi-core processing.
parfor pnt = 1:Np
    % Phase adjustment to align signals originating from the current focal point (pnt)
    phase = exp(1j * two_pi_f * delays(:,pnt).');
    % Coherently sum across all frequencies for the aligned signals
    sig = sum(data .* phase, 1);

    switch method
        case 'DAS'
            % --- Delay and Sum ---
            % PHYSICAL CONCEPT: Simplest beamformer. Assumes isotropic scattering.
            % Signals sum constructively if a scatterer is present.
            s = sum(sig);
        case 'DMAS'
            % --- Delay Multiply and Sum ---
            % PHYSICAL CONCEPT: Multiplies aligned signals pairwise to enhance correlation
            % (coherence) between channels, which effectively suppresses uncorrelated noise/clutter.
            % PERFORMANCE ENHANCEMENT: Nested loops are slow in MATLAB. This can be completely
            % vectorized using: s = 0.5 * (sum(sig)^2 - sum(sig.^2)); or by matrix operations.
            s = 0.5 * (sum(sig)^2 - sum(sig.^2));
        case 'CF'
            % --- Coherence Factor ---
            coherent = abs(sum(sig));
            incoherent = sum(abs(sig));
            cf = coherent / (incoherent + eps);
            s = cf * sum(sig);
        case 'MVDR'
            % --- Minimum Variance Distortionless Response ---
            % PHYSICAL CONCEPT: An adaptive beamformer that minimizes total output power
            % (noise + clutter) while maintaining a distortionless response (gain = 1)
            % in the look direction (the current focal point).
            R = (sig.' * conj(sig)) / Nc + 1e-6 * eye(Nc);
            a = ones(Nc,1); % Steering vector (ones because we already applied delays)
            R_inv_a = R \ a;
            w = R_inv_a / (a' * R_inv_a);
            s = w' * sig.';
        case 'CAPON'
            % --- Capon (MVDR Spectral) ---
            % PERFORMANCE ENHANCEMENT: R \ a is computed twice in MVDR and Capon.
            % It can be stored in a temporary variable to avoid redundant matrix inversions.
            R = (sig.' * conj(sig)) / Nc + 1e-6 * eye(Nc);
            a = ones(Nc,1);
            R_inv_a = R \ a;
            s = 1 / real(a' * R_inv_a);
        case 'MUSIC'
            % --- MUSIC Algorithm ---
            % PHYSICAL CONCEPT: A high-resolution subspace method. Decomposes the spatial
            % covariance matrix into signal and noise subspaces. The spectrum peaks where
            % the steering vector is orthogonal to the noise subspace.

            % 1. Covariance Matrix
            R = (sig.' * conj(sig)) / Nc;

            % 2. Eigendecomposition
            % PERFORMANCE ENHANCEMENT: For large Nc, full eigendecomposition (eig) is costly.
            % Consider using svd() or eigs() if you only need a few principal components.
            [V, D] = eig(R);
            eigenvals = diag(D);
            [eigenvals, idx] = sort(eigenvals, 'descend');
            V = V(:, idx);

            % 3. Determine Noise Subspace
            En = V(:, 2:end);


            % 4. MUSIC Spectrum
            % Note: Steering vector 'a' is effectively ones(Nc,1)
            % because 'sig' is already phase-aligned (focused).
            a = ones(Nc, 1);
            denom = norm(En' * a)^2; % identical to a' * En * En' * a
            s = 1 / (denom + 1e-12);
    end
    image_vec(pnt) = abs(s)^powerExp;
end

% ---------------------------
% Normalize
if doNorm
    m = max(image_vec);
    if m ~= 0
        image_vec = image_vec / m;
    end
end
end