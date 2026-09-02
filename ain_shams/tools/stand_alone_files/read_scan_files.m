function [frequencies , Scan] = read_scan_files(filePath)

raw = readcell(filePath);
frequencies = cell2mat(raw(2:end, 1)) * 1e9;

raw = raw(2:end, 2:end);
parsed = cellfun(@str2num, raw, 'UniformOutput', false); 
Scan = cell2mat(parsed);   
end

