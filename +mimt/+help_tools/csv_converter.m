function scan = csv_converter(input_file, output_file, num_frequencies, num_channels)
    % This function change input file size num_frequencies*numchannels X 3 
    % To be output function with size num_frequencies X num_channels each
    % cell has a complex numbers of (real + i img) value
    
data = dlmread(input_file);

scan = zeros(num_frequencies, num_channels);

for ch = 1:num_channels
    idx = (ch-1)*num_frequencies + (1:num_frequencies);
    scan(:, ch) = data(idx, 2) + 1i * data(idx, 3);
end
    % Write output to CSV file
    writematrix(scan, output_file);
end