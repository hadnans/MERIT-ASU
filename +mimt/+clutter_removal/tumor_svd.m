% --- INPUT ---
% M : N_meas x N_freq complex matrix of S-parameters
%     (rows = antenna pairs, columns = frequencies)
% baseline : same size as M (healthy reference)
% energy_thresh : percentage of energy to keep (e.g. 0.9 for 90%)

function [M_recon, R, k] = tumor_svd(M, baseline, energy_thresh)

    % 1) Background removal
    M_diff = M - baseline;

    % 2) SVD decomposition
    [U, S, V] = svd(M_diff, 'econ');
    s = diag(S);   % singular values

    % 3) Pick top-k components (energy-based threshold)
    energy = s.^2;
    cumEnergy = cumsum(energy) / sum(energy);
    k = find(cumEnergy >= energy_thresh, 1, 'first');

    % 4) Reconstruct tumor-related signal
    U_k = U(:,1:k);
    S_k = S(1:k,1:k);
    V_k = V(:,1:k);
    M_recon = U_k * S_k * V_k';

    % 5) Residual (clutter + noise)
    R = M_diff - M_recon;

    % --- OPTIONAL: quick diagnostic plots ---
    % figure;
    % subplot(1,2,1);
    % semilogy(s,'o-'); grid on;
    % xlabel('Index'); ylabel('Singular Value');
    % title('Singular Spectrum');
    % 
    % subplot(1,2,2);
    % imagesc(abs(M_recon)); colorbar;
    % title(['Reconstructed tumor signal (k = ' num2str(k) ')']);
    % xlabel('Frequency index'); ylabel('Measurement index');

end
