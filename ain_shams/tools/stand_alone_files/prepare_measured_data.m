clearvars; clc;

files = dir('adnan\data\measured\All Except conseq and serf\Tumored All\S21_cartesianed\*.csv'); 
frequencies = readmatrix("adnan\data\measured\frequencies.csv");

data = zeros(length(frequencies), length(files));
for k = 1:length(files)
    filename = files(k).name;
    % Example for loading .mat files
    col = readmatrix(filename); 
    data(:, k) = col;
end
writematrix(data, 'adnan\data\measured\All Except conseq and serf\Tumored All\scan2.csv');
%%
clearvars; clc;

files = dir('adnan\data\measured\All Except conseq and serf\Non Tumored ALl\S21_cartesianed\*.csv'); 
frequencies = readmatrix("adnan\data\measured\frequencies.csv");

data = zeros(length(frequencies), length(files));
for k = 1:length(files)
    filename = files(k).name;
    % Example for loading .mat files
    col = readmatrix(filename); 
    data(:, k) = col;
end
writematrix(data, 'C:\Users\AbdElrahman\Documents\abdelrahman\signal_processing\adnan\data\measured\All Except conseq and serf\Non Tumored ALl\scan1.csv');
%%
clearvars; clc;

files = dir('adnan\data\measured\All Except conseq and serf\Tumored All\S21_cartesianed\*.csv'); 
frequencies = readmatrix("adnan\data\measured\frequencies.csv");

data = zeros(1, length(files));
for k = 1:length(files)
    filename = files(k).name;
    
    data(1, k) = filename;
end
%%
% frequencies = linspace(3e8,6.3e9,1001);
% frequencies = frequencies';
% writematrix(frequencies, 'adnan\data\measured\frequencies.csv');