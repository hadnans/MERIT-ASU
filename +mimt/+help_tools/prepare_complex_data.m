function prepare_complex_data(folder_path, output_folder)
    % PREPARE_HFSS_FOLDER - Process all CSV files in a folder and save cleaned data
    %
    % Usage:
    %   prepare_hfss_folder('path/to/input', 'path/to/output')

    % Ensure output folder exists
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Get all CSV files
    files = dir(fullfile(folder_path, '*.csv'));

    for k = 1:length(files)
        file_name = fullfile(folder_path, files(k).name);
        fprintf('Processing: %s\n', files(k).name);

        % Read file
        [num, str, raw] = xlsread(file_name);

        % Convert mixed content
        rawval = double(cellfun(@(x) ~isnumeric(x), raw));
        a = zeros(size(raw));
        b = a;
        a(rawval == 0) = cell2mat(raw(rawval == 0));
        b(rawval == 1) = str2double(raw(rawval == 1));
        Matrix = a + b;

        % Extract frequencies and data
        frequencies = Matrix(2:end, 1);
        data = Matrix(2:end, 2:end);

        % Save cleaned data
        [~, name, ~] = fileparts(files(k).name);
        output_file = fullfile(output_folder, [name '_prepared.csv']);
        writematrix(data, output_file);

        if k == 1
            frequencies_file = fullfile(output_folder, 'frequencies.csv');
            writematrix(frequencies, frequencies_file);
            fprintf('Saved: %s\n', frequencies_file);
        end
           
        fprintf('Saved: %s\n', output_file);
    end
end
