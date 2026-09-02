function [scan2, scan1, frequencies, sensors_locations, channel_names] = load_data_asu(data, conf_pol, channels_mode)
    

% % load data 
% data :0 => simulation , 1 => measured, 2 => all
% conf_pol : 11, 12, 21,22
% channels_mode : 1 | 2 | 3 % select mono/multi static system

if data == 0  
    % change the frequency band between 1 - 8 GHz
    if conf_pol == 11
        scan1 = readmatrix("ain_shams\data\phantom150\prepared\LR_scan1.csv");
        scan2 = readmatrix("ain_shams\data\phantom150\prepared\LR_scan2.csv");
       
        channel_names = readmatrix("ain_shams\data\phantom150\channel_names.csv");
        frequencies = readmatrix("ain_shams\data\phantom150\frequencies.csv")*1e9;
        sensors_locations = readmatrix("ain_shams\data\phantom150\antenna_locations_R.csv")*1e-3;
    elseif conf_pol == 21
        % scan1 = readmatrix("ain_shams\data\phantom150\prepared\CR_scan1.csv");
        % scan2 = readmatrix("ain_shams\data\phantom150\prepared\CR_scan2.csv");
        scan2 = readmatrix("ain_shams\data\phantom150\prepared\102025\circular_round_tumor_table_data_27102025_prepared.csv");
        scan1 = readmatrix("ain_shams\data\phantom150\prepared\102025\circular_round_NO_tumor_table_data_27102025_prepared.csv");
       
        channel_names = readmatrix("ain_shams\data\phantom150\channel_names.csv");
        frequencies = readmatrix("ain_shams\data\phantom150\frequencies.csv")*1e9;
        sensors_locations = readmatrix("ain_shams\data\phantom150\antenna_locations_R.csv")*1e-3;
    elseif conf_pol == 12
        scan1 = readmatrix("ain_shams\data\phantom150\prepared\LC_scan1.csv");
        scan2 = readmatrix("ain_shams\data\phantom150\prepared\LC_scan2.csv");
       
        channel_names = readmatrix("ain_shams\data\phantom150\channel_names.csv");
        frequencies = readmatrix("ain_shams\data\phantom150\frequencies.csv")*1e9;
        sensors_locations = readmatrix("ain_shams\data\phantom150\antenna_locations_C.csv")*1e-3;
    elseif conf_pol == 22
        % scan1 = readmatrix("ain_shams\data\phantom150\prepared\CC_scan1.csv");
        % scan2 = readmatrix("ain_shams\data\phantom150\prepared\CC_scan2.csv");
        scan2 = readmatrix("ain_shams\data\phantom150\prepared\102025\with Tumor Circular Cross_prepared.csv");
        scan1 = readmatrix("ain_shams\data\phantom150\prepared\102025\No Tumor Circular Cross_prepared.csv");
       
        channel_names = readmatrix("ain_shams\data\phantom150\channel_names.csv");
        frequencies = readmatrix("ain_shams\data\phantom150\frequencies.csv")*1e9;
        sensors_locations = readmatrix("ain_shams\data\phantom150\antenna_locations_C_g.csv")*1e-3;
    end
    
    if channels_mode == 1
        [scan2, scan1, channel_names] = mimt.manage_data.remove_transmissions(scan2, scan1, channel_names);
    elseif channels_mode == 2
        [scan2, scan1, channel_names] = mimt.manage_data.remove_reflections(scan2, scan1, channel_names);
%       [scan2, scan1, channel_names] = remove_reversed_pairs(scan2, scan1, channel_names);
    elseif channels_mode == 3
        % remove nothing
    end 

elseif data == 1 
    if conf_pol == 12
        folderPath = 'ain_shams\data\measured\nanoVNA\LP_Cross\without_tumor'; % Replace with your actual folder path
        [scan1, ~] = read_s2p_files(folderPath);
        folderPath = 'ain_shams\data\measured\nanoVNA\LP_Cross\with_tumor'; % Replace with your actual folder path
        [scan2, frequencies, ~, ~] = read_s2p_files(folderPath);
        channel_names = readmatrix("ain_shams\data\measured\nanoVNA\channel_names.csv");
        
    elseif conf_pol == 22
        folderPath = 'ain_shams\data\measured\nanoVNA\CP_Cross\without_tumor'; % Replace with your actual folder path
        [scan1, ~] = read_s2p_files(folderPath);
        folderPath = 'ain_shams\data\measured\nanoVNA\CP_Cross\with_tumor'; % Replace with your actual folder path
        [scan2, frequencies, ~, ~] = read_s2p_files(folderPath);
    
        channel_names = readmatrix("ain_shams\data\measured\nanoVNA\channel_names.csv");
    end
    sensors_locations = evaluate_sensors_locations(0.083,40,0.02,0.1);
    
    if channels_mode == 1
        fprintf("reflections\n");
        [scan2, scan1, channel_names] = mimt.manage_data.remove_transmissions(scan2, scan1, channel_names);
    elseif channels_mode == 2
        fprintf("transmissions\n");
        [scan2, scan1, channel_names] = mimt.manage_data.remove_reflections(scan2, scan1, channel_names);
%       [scan2, scan1, channel_names] = remove_reversed_pairs(scan2, scan1, channel_names);
    elseif channels_mode == 3
        fprintf("all matrix\n");
        % remove nothing
    end 

elseif data == 2 
    % frequency range from 1 to 5GHz
    
    if conf_pol == 11
        scan2 = readmatrix("ain_shams\data\all\Round Linear\Round Linear.csv");
        scan1 = scan2;    
        sensors_locations = readmatrix("ain_shams\data\all\Round Linear\Antenna Locations.xlsx")*1e-3;
    elseif conf_pol == 12
         scan2 = readmatrix("ain_shams\data\all\Round Circular\Round Circular.csv");
        scan1 = scan2;
         sensors_locations = readmatrix("ain_shams\data\all\Round Circular\Antenna Locations.xlsx")*1e-3;
    elseif conf_pol == 21
         scan2 = readmatrix("ain_shams\data\all\Cross Linear\Cross Linear.csv");
        scan1 = scan2;
        sensors_locations = readmatrix("ain_shams\data\all\Cross Linear\Antenna Locations.xlsx")*1e-3;
    elseif conf_pol == 22
        scan2 = readmatrix("ain_shams\data\all\Cross Circular\Cross Circular.csv");
        scan1 = scan2;
        sensors_locations = readmatrix("ain_shams\data\all\Cross Circular\Antenna Locations.xlsx")*1e-3;
    end
    frequencies = readmatrix("ain_shams\data\all\frequencies.csv");
    channel_names = readmatrix("ain_shams\data\all\channel_names.csv");

    if channels_mode == 1
       [scan2, scan1, channel_names] = mimt.manage_data.remove_transmissions(scan2, scan1, channel_names);
    elseif channels_mode == 2
        [scan2, scan1, channel_names] = mimt.manage_data.remove_reflections(scan2, scan1, channel_names);
        [scan2, scan1, channel_names] = mimt.manage_data.remove_reversed_pairs(scan2, scan1, channel_names);
    elseif channels_mode == 3
        % remove nothing
    end 

end