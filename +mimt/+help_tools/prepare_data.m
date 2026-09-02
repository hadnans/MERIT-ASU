% this file removes the not number values thin convert them to the proper
% format 
clc, clearvars, close all
% 
% no_tumor = readmatrix('cst_data/9_antennas/15/no_tumor.csv'); % No tumor scan
% one_tumor = readmatrix('cst_data/9_antennas/15/one_tumor.csv'); % One Tumor 
% two_tumors = readmatrix('cst_data/9_antennas/15/two_tumors.csv'); % Two Tumor 
% 
% n = ~isnan(one_tumor(:,1));
% 
% no_tumor = no_tumor(n,:);
% one_tumor = one_tumor(n,:);
% two_tumors = two_tumors(n,:);
% 
% writematrix(no_tumor, ...
%     'cst_data/9_antennas/15/no_tumor_S_parameters.csv');
% writematrix(one_tumor, ...
%     'cst_data/9_antennas/15/one_tumor_S_parameters.csv');
% writematrix(two_tumors, ...
%     'cst_data/9_antennas/15/two_tumors_S_parameters.csv');
% 
% csv_converter('cst_data/9_antennas/15/no_tumor_S_parameters.csv', ...
%     'cst_data/9_antennas/15/scan1.csv', 1001, 81);
% csv_converter('cst_data/9_antennas/15/one_tumor_S_parameters.csv', ...
%     'cst_data/9_antennas/15/scan2.csv', 1001, 81);
% csv_converter('cst_data/9_antennas/15/two_tumors_S_parameters.csv', ...
%     'cst_data/9_antennas/15/scan3.csv', 1001, 81);
% 
% data = readmatrix('./al_azhar/cst_data/9_round/two_layers/no_tumor.csv'); % Two Tumor 
% n = ~isnan(data(:,1));
% data = data(n,:);
% writematrix(data, './al_azhar/cst_data/9_round/two_layers/no_tumor_matrix.csv');
% 
% csv_converter('./al_azhar/cst_data/9_round/two_layers/no_tumor_matrix.csv', ...
%     './al_azhar/cst_data/9_round/two_layers/scan1.csv', 1001, 81);

s_real = readmatrix("al_azhar\hfss_data\RAW\S Parameter real.csv");
s_imag = readmatrix("al_azhar\hfss_data\RAW\S Parameter imaginary.csv");

frequencies = s_real(:, 1);
writematrix(frequencies, 'al_azhar\hfss_data\9_sensors\frequencies.csv');
s_real = s_real(:, 2:end);
s_imag = s_imag(:, 2:end);

[F, N] = size(s_real);
s_matrix = zeros(F, N);

for i = 1 : N
    s_matrix(:, i) = s_real(:, i) + s_imag(:, i) * 1j;
end

writematrix(s_matrix, 'al_azhar\hfss_data\9_sensors\scan2.csv');