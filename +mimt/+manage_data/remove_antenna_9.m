function [scan2, scan1, channel_names] = remove_antenna_9(scan2, scan1, channel_names)
    n = channel_names(:,1) ~= 9 & channel_names(:, 2) ~= 9;
    
    channel_names = channel_names(n, :);
    
    scan2 = scan2(:, n);
    scan1 = scan1(:, n);
end