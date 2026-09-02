channel_names = zeros(12, 2);
for i = 1 : 12
    tx = i;
    rx = i + 12;
    channel_names(i, 1) = tx;
    channel_names(i, 2) = rx;
end
writematrix(channel_names, 'measured\channel_names.csv');