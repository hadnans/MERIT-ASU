function cleaned_signal = differential(signals, x)
% Input: signal (NxM complex matrix)
% Output: cleaned_signal (NxM complex matrix)

shifted_signals = circshift(signals, [0 , x]);
cleaned_signal = signals - shifted_signals;        % Subtract clutter from each column
end