function [signals_scaled] = scale_reflections(signals, channel_names, scale_db)
    signals_scaled = signals;
    n = channel_names(:, 1) == channel_names(:, 2);
    signals_scaled(:, n) = signals(:, n) * (db2mag(scale_db));
end