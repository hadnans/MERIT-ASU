function cleaned_signal = time_gating(signals, margin)
    [N, M] = size(signals);
    cleaned_signal = zeros(N, M);

    for m = 1:M
        signal_m = signals(:, m);
        [~, peak_idx] = max(abs(signal_m));

        % Define symmetric gating window
        start_idx = 1;
        end_idx = min(N, peak_idx + margin);

        % Keep only the gated segment
        signal_m(start_idx:end_idx) = 0;

        cleaned_signal(:, m) = signal_m;
    end
end
