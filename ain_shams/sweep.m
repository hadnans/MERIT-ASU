clc, clearvars, close all

%--------------------------------
% Data Options 
% -------------------------------
data = 0;
conf_pol= 22;
channels_mode = 3;

% -------------------------------
% Imaging Domain Parameters
% -------------------------------
ROI                    = 0.075;   % phantom radious (region of interest)
slice                  = 0.03;    % slice position in z direction
resolution             = 2.5e-3;
% relative_permittivity  = 1;
thresholding_diff      = 0; % 0: use scan2, 1: use |scan2-scan1|
scale_factor = -40;

% -------------------------------
% Processing Options (0 | 1)
% -------------------------------
background_subtraction = 1; 
rotated_subtraction    = 0; 
time_domain_processing = 0; 
time_gating_cr         = 0; 
av_sub_cr              = 1; 
filter_cr              = 0;
svd_cr                 = 0;
estimated_delay        = 1;
algorithm              = 1;
method                 = 'DAS'; % DAS, DMAS, CF, MVDR, CAPON

feed_permittivity = 1;
if conf_pol == 12 || conf_pol == 11
    feed_d = 20e-3; %CP=15 % LP = 21
    gap    = 2.7e-3; % gap = 2.7158e-3; (disabled)
elseif conf_pol == 21 || conf_pol == 22
    feed_d = 15e-3; %CP=15 % LP = 21
    gap    = 2.7e-3; % gap = 2.7158e-3; (disabled)
end

% -------------------------------
% Parameter ranges to sweep
% -------------------------------
relative_permittivity_list = [1, 3];
f_start_list     = [1e9, 2e9, 3e9, 4e9];        % GHz start frequencies
f_end_list       = [2e9, 3e9, 4e9, 5e9];        % GHz end frequencies
freq_step_list   = [1, 2, 8];          % step sizes
threshold_list   = [-40, -45, -50, -55, -60, -65, -70];     % dB thresholds

% -------------------------------
% Tumor detection save condition
% -------------------------------
tumor_x_min = 10;   % adjust as needed
tumor_y_min = 10;
% -------------------------------
params.ROI                      = ROI;
params.slice                    = slice;   
params.resolution               = resolution;
params.thresholding_diff        = thresholding_diff;
params.background_subtraction   = background_subtraction;
params.rotated_subtraction      = rotated_subtraction;
params.time_domain_processing   = time_domain_processing;
params.time_gating_cr           = time_gating_cr;
params.av_sub_cr                = av_sub_cr;
params.filter_cr                = filter_cr;
params.svd_cr                   = svd_cr;
params.estimated_delay          = estimated_delay;
params.feed_permittivity        = feed_permittivity;
params.feed_d                   = feed_d;
params.gap                      = gap;
params.algorithm                = algorithm;
params.method                   = method;
% -------------------------------
% Sweeping loop
% -------------------------------
iteration = 1;
for relative_permittivity = relative_permittivity_list
    for f_start = f_start_list
        for f_end = f_end_list
            for freq_step = freq_step_list
                for signal_threshold = threshold_list
                    fprintf('Iteration %d out of %d\n', iteration, ...
                            length(f_start_list) * length(f_end_list) * ...
                            length(freq_step_list) * length(threshold_list) * length(relative_permittivity_list));
                    iteration = iteration + 1;          
                    if f_end <= f_start
                        continue; % skip invalid ranges
                    end
                   
                    [scan2, scan1, frequencies, sensors_locations, channel_names] =  ...
                                load_data_asu(data, conf_pol, channels_mode);
                    scan2 = mimt.manage_data.scale_reflections(scan2, channel_names, scale_factor);
                    scan1 = mimt.manage_data.scale_reflections(scan1, channel_names, scale_factor);
                    try
                        params.scan2                 = scan2;
                        params.scan1                 = scan1;
                        params.frequencies           = frequencies;
                        params.sensors_locations     = sensors_locations;
                        params.channel_names         = channel_names;
                        params.relative_permittivity = relative_permittivity;
                        params.f_start               = f_start;
                        params.f_end                 = f_end;
                        params.freq_step             = freq_step;
                        params.signal_threshold      = signal_threshold;
                        [img, tumor_x, tumor_y]      = mimt.process.compute_beamform(params);     
                    catch exception
                        continue;
                    end
                    
                    % Check condition and save results
                    % if (tumor_x > tumor_x_min) && (tumor_y > tumor_y_min)
                    
                        fname = sprintf('./ain_shams/results/sweep/cc/wr_112025/Result_er_%.1f_f%.2f-%.2fGHz_step%d_thr%+d_x%.3f_y%.3f', ...
                                        relative_permittivity, f_start/1e9, f_end/1e9, freq_step, signal_threshold, ...
                                        tumor_x, tumor_y);
                        
                        % Save figure
                        saveas(gcf, [fname '.png']);
                    % end  
                    
                    close all % close figures before next iteration      
                end
            end
        end
    end
end
