function [scan2, scan1, frequencies] = adjust_freq_step(scan2, scan1, frequencies, step)
    n = 1:step:numel(frequencies);
    frequencies = frequencies(n);
    scan2 = scan2(n,:);
    scan1 = scan1(n,:);
end
