function [scan2, scan1, channel_names] = remove_reversed_pairs(scan2, scan1, channel_names)
    n = find (channel_names(:, 1) >= channel_names(:, 2));
    channel_names = channel_names(n,:);
    scan1 = scan1(:, n);
    scan2 = scan2(:, n);
end