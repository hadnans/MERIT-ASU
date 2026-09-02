function [clean_signals, W] = adaptive_filter(signals, ref_idx, mu, filter_order, type)
    [N, M] = size(signals);
    clean_signals = zeros(N, M);
    W = zeros(filter_order, M);

    ref_signal = signals(:, ref_idx);  
    
    for ch = 1:M
        if ch == ref_idx
            clean_signals(:, ref_idx) = signals(:, ref_idx); % keep ref unchanged
            continue; 
        end

        d = signals(:, ch);  % desired signal
        x = ref_signal;

        w = zeros(filter_order,1);
        e = zeros(N,1);

        delta = 1e-6; 
        for n = filter_order:N
            x_vec = x(n:-1:n-filter_order+1);   
            y = w' * x_vec;                    
            e(n) = d(n) - y;                   
            
            if type == 0   % LMS
                w = w + mu * e(n) * x_vec;  
            else           % NLMS
                norm_factor = (x_vec' * x_vec) + delta;
                w = w + (mu / norm_factor) * e(n) * x_vec; 
            end
        end

        clean_signals(:, ch) = e;
        W(:, ch) = w;
    end
end
