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
c0 = 299792458;
speed = c0 / sqrt(eps_r);
tx_idx = channel_names(:,1);
rx_idx = channel_names(:,2);
tx_pos = sensors_loc(tx_idx,:);
rx_pos = sensors_loc(rx_idx,:);

dist_tx = pdist2(tx_pos, grid_pts);
dist_rx = pdist2(rx_pos, grid_pts);
% Negative for back-propagation
delays = -extra_delay - (dist_tx + dist_rx) / speed;

% ---------------------------
% Main loop over pixels
for pnt = 1:Np
    phase = exp(1j * two_pi_f * delays(:,pnt).');
    sig = sum(data .* phase, 1); 

    switch method
        case 'DAS'
            % --- Delay and Sum ---
            s = sum(sig);
        case 'DMAS'
            % --- Delay Multiply and Sum ---
            s = 0;
            for i = 1:Nc-1
                for j = i+1:Nc
                    s = s + sig(i) * conj(sig(j));
                end
            end
        case 'CF'
            % --- Coherence Factor ---
            coherent = abs(sum(sig));
            incoherent = sum(abs(sig));
            cf = coherent / (incoherent + eps);
            s = cf * sum(sig);
        case 'MVDR'
            % --- Minimum Variance Distortionless Response ---
            R = (sig.' * conj(sig)) / Nc + 1e-6 * eye(Nc);
            a = ones(Nc,1);
            w = (R \ a) / (a' * (R \ a));
            s = w' * sig.';
        case 'CAPON'
            % --- Capon (MVDR Spectral) ---
            R = (sig.' * conj(sig)) / Nc + 1e-6 * eye(Nc);
            a = ones(Nc,1);
            s = 1 / real(a' * (R \ a)); 
        case 'MUSIC'
            % --- MUSIC Algorithm ---
            % 1. Covariance Matrix
            R = (sig.' * conj(sig)) / Nc;
            
            % 2. Eigendecomposition
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