function [img, tumor_x, tumor_y] = compute_beamform(params)
    % ==============================================================
    % Breast Cancer Detection Imaging Function
    % ==============================================================
    % Inputs:
    %   params — struct containing all necessary parameters and data
    % Example:
    %   [img, tx, ty] = breast_cancer_imaging(params);
    % ==============================================================
    
    % -------------------------------
    % Extract fields from struct
    % -------------------------------
    scan2                   = params.scan2;
    scan1                   = params.scan1;
    frequencies             = params.frequencies;
    sensors_locations       = params.sensors_locations;
    channel_names           = params.channel_names;
    f_start                 = params.f_start;
    f_end                   = params.f_end;
    freq_step               = params.freq_step;
    ROI                     = params.ROI;
    slice                   = params.slice;
    resolution              = params.resolution;
    relative_permittivity   = params.relative_permittivity;
    signal_threshold        = params.signal_threshold;
    thresholding_diff       = params.thresholding_diff;
    background_subtraction  = params.background_subtraction;
    rotated_subtraction     = params.rotated_subtraction;
    time_domain_processing  = params.time_domain_processing;
    time_gating_cr          = params.time_gating_cr;
    av_sub_cr               = params.av_sub_cr;
    filter_cr               = params.filter_cr;
    svd_cr                  = params.svd_cr;
    estimated_delay         = params.estimated_delay;
    feed_permittivity       = params.feed_permittivity;
    feed_d                  = params.feed_d;
    gap                     = params.gap;
    algorithm               = params.algorithm;
    method                  = params.method;
    
    % ==============================================================
    % -------------------------------
    % Preprocessing
    % -------------------------------
    [scan2, scan1, frequencies] = mimt.manage_data.adjust_freq_step(scan2, scan1, frequencies, freq_step);
    
    % -------------------------------
    % Feeding Delay Calculation
    % -------------------------------
    if estimated_delay == 1 
        fprintf("Estimated Delay\n");
    elseif estimated_delay == 0
        feed_d = 0;
        gap    = 0; 
    end
    c_0    = 299792458;  
    v_feed = c_0 / sqrt(feed_permittivity);
    extra_delay = (feed_d / v_feed) + (gap / c_0);
    
    % -------------------------------
    % Rotated Subtraction
    % -------------------------------
    if rotated_subtraction == 1
        fprintf("Rotated Subtraction\n");
        scan1 = mimt.manage_data.rotate_data_set(scan2, size(sensors_locations, 1), channel_names);
    end
    
    % -------------------------------
    % Frequency Selection
    % -------------------------------
    frequency_range = find(frequencies(:,1) >= f_start & frequencies(:,1) <= f_end);
    frequencies     = frequencies(frequency_range,:);
    scan2           = scan2(frequency_range, :);
    scan1           = scan1(frequency_range, :);
    
    % -------------------------------
    % Thresholding Channels
    % -------------------------------
    if signal_threshold < 0
        fprintf("Thresholding Channels\n");
        if thresholding_diff == 1
            avg = mean(mag2db(abs(scan2 - scan1)), 1);
        else
            avg = mean(mag2db(abs(scan2)), 1);
        end
        valid   = avg >= signal_threshold;
        scan2 = scan2(:, valid);
        scan1 = scan1(:, valid);
        channel_names = channel_names(valid, :);
    end
    % -------------------------------
    % Background / Rotated Subtraction
    % -------------------------------
    if background_subtraction == 1
        fprintf("Background Subtraction\n");
        signals = scan2 - scan1;
    elseif background_subtraction == 0
        signals = scan2;
    elseif rotated_subtraction == 1
        signals = scan2 - scan1;
    end
    
    % -------------------------------
    % Domain & Delays
    % -------------------------------
    [points, ~] = merit.domain.hemisphere(ROI, 'resolution', resolution);
    if algorithm == 0
        delays = merit.beamform.get_delays(channel_names, sensors_locations, ...
            'relative_permittivity', relative_permittivity, ...
            'extra_delay', 2 * extra_delay);
    end
    
    % -------------------------------
    % Time Domain Processing
    % -------------------------------
    if time_domain_processing == 1
        fprintf("Time domain processing\n");
        df        = frequencies(2) - frequencies(1);
        T         = 1/df;
        dt        = 1/(2*frequencies(end));
        time_axis = 0:dt:T;
    
        signals = merit.process.fd2td(signals, frequencies, time_axis);
    end
    
    % -------------------------------
    % Clutter Removal
    % -------------------------------
    if time_gating_cr == 1
        fprintf("Time gating\n");
        signals = mimt.clutter_removal.time_gating(signals, 50);
    end
    
    if av_sub_cr == 1
        fprintf("Average subtraction\n");
        signals = mimt.clutter_removal.average_subtraction(signals);
    end
    
    if filter_cr == 1
        fprintf("Adaptive filter\n");
        signals = mimt.clutter_removal.adaptive_filter(signals, 1, 0.01, 32, 0);
    end
    
    if svd_cr == 1 
        fprintf("SVD Clutter Removal\n");
        [M_recon, ~, ~] = mimt.clutter_removal.tumor_svd(signals, mean(signals, 2), 0.9);
        signals = M_recon;  
    end
    
    % -------------------------------
    % Back to frequency domain
    % -------------------------------
    if time_domain_processing == 1 
        signals = merit.process.td2fd(signals, time_axis, frequencies);
    end
    
    % -------------------------------
    % Info Logging
    % -------------------------------
    fprintf("Num of Points %d\n", size(points, 1));
    fprintf("Num of Sensors %d\n", size(sensors_locations, 1));
    fprintf("Num of Channels %d\n", size(channel_names, 1));
    fprintf("Signals Threshold %d dB\n", signal_threshold);
    fprintf("Relative Permittivity = %.1f\n", relative_permittivity);
    fprintf("Phantom Radius = %d mm\n", ROI * 1e3);
    fprintf("From %.1f to %.1f GHz\n", frequencies(1)/1e9, frequencies(end)/1e9);
    fprintf("Num of Sample Frequencies = %d\n", size(frequencies, 1));
    fprintf("Loading..\n");
    
    % -------------------------------
    % Beamforming
    % -------------------------------
    switch algorithm
        case 0
            img = abs(merit.beamform(signals, frequencies, points, delays, ...
                merit.beamformers.DAS, "max_memory", 15e9));
            img = img / max(img);
        case 1
            img = mimt.process.beamformer_freq_domain(signals, frequencies, channel_names, sensors_locations, points, ...
                'relative_permittivity', relative_permittivity, ...  
                'extra_delay', extra_delay, ...
                'method', method, ...
                'normalize', true, ...
                'power', 2);
    end
    
    % -------------------------------
    % Tumor Info
    % -------------------------------
    [tumor_x, tumor_y] = mimt.process.calculate_tumor_info(points, img, slice, 1e-4, 0.6);
    
    % -------------------------------
    % Display Images
    % -------------------------------
    points_mm = points * 1e3;
    sensors_locations_mm = sensors_locations * 1e3;
    slice_mm = slice * 1e3;
    
    if max(img) == min(img)
        return;
    end

    subplot(1,2,1);
    mimt.visualization.display_2d(img, points_mm, 3, slice_mm, resolution);
    colormap("jet");
    colorbar;
    set(gca, 'FontSize', 20);
    drawnow;
    
    subplot(1,2,2);
    cla;
    mimt.visualization.display_3d(img, points_mm, sensors_locations_mm, 0.8);
    colormap("jet");
    colorbar;
    set(gca, 'FontSize', 20);
    drawnow;
end