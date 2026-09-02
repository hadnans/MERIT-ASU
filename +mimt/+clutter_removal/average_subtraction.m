function cleaned_signal = average_subtraction(signals)
% Input: signal (NxM complex matrix)
% Output: cleaned_signal (NxM complex matrix)

clutter = mean(signals, 2);         % Average across columns (channels)
cleaned_signal = signals - clutter;        % Subtract clutter from each column

end