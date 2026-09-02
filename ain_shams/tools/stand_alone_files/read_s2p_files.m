function [scan, frequencies, nR, nT] = read_s2p_files(folderPath)
    % inputs:
    %   folderPath : the path to the s2p files folder
    % output:
    % scan : a matrix of the data num of frequencies x num of channels
    % frequencies : a frequencies samples in Hz
    % Get a listing of all files and subfolders within the specified folder
    fileList = dir(folderPath);
    
    % Initialize a cell array to store file names
    fileNames = {};
    
    % Loop through the fileList structure
    for i = 1:length(fileList)
        % Check if the current item is a file and not '.' or '..' (current/parent directory)
        if ~fileList(i).isdir && ~strcmp(fileList(i).name, '.') && ~strcmp(fileList(i).name, '..')
            % Add the file name to the fileNames cell array
            fileNames{end+1} = fileList(i).name;
        end
    end
    
    S = sparameters(fileNames{1});
    frequencies = S.Frequencies;
    S = S.Parameters;
    S = squeeze(S(1,1,:));
    
    num_of_samples  = size(S, 1);
    scan = zeros(num_of_samples, length(fileNames));
    nR = 0;
    nT = 0;
    for file = 1 : length(fileNames)
         if mod(file-1,9) == 0   % first element in each group of 9
            data = sparameters(fileNames{file});
            s_parameter = data.Parameters;
            s_parameter = squeeze(s_parameter(1,1,:));
            scan(:,file) = s_parameter;
            nR = nR + 1;
        else
            data = sparameters(fileNames{file});
            s_parameter = data.Parameters;
            s_parameter = squeeze(s_parameter(2,1,:));
            scan(:,file) = s_parameter;
            nT = nT + 1;
         end
    end
end