clc, clearvars, close all
%--------------------------------
% Data Options
% -------------------------------
data = 0;
conf_pol= 12;
channels_mode = 3;

% -------------------------------
% Imaging Domain Parameters
% -------------------------------
% PHYSICAL CONCEPT: ROI defines the maximum radius of the breast phantom.
% We only reconstruct the image inside this volume to save computation time.
ROI                    = 0.075;   % phantom radious (region of interest)
slice                  = 0.03;    % slice position in z direction
% PERFORMANCE ENHANCEMENT: Resolution controls the grid density (voxel size).
% Finer resolution (e.g., 1e-3) increases image quality but causes memory and
% computational time to scale cubically (O(N^3)). Start coarse (2.5e-3), then refine.
resolution             = 2.5e-3;
% PHYSICAL CONCEPT: relative_permittivity (eps_r) is the most critical parameter.
% It dictates the assumed speed of the microwave signal in the breast tissue.
% An incorrect eps_r will blur the image or shift the tumor location.
relative_permittivity  = 1;
signal_threshold       = -55;
thresholding_diff      = 0;       % 0: use scan2, 1: use |scan2-scan1|
scale_factor = -40;

% -------------------------------
% Processing Options (0 | 1)
% -------------------------------
% PHYSICAL CONCEPT: Background subtraction removes the antenna coupling and static
% reflections by subtracting a scan of an empty system (scan1) from the tumor scan (scan2).
background_subtraction = 1;
rotated_subtraction    = 0;
time_domain_processing = 0;
time_gating_cr         = 0;
av_sub_cr              = 1;
filter_cr              = 0;
svd_cr                 = 0;
estimated_delay        = 1;
algorithm              = 1;     % 0 for MERIT, 1 for MIMT
method                 = 'DAS'; % DAS, DMAS, CF, MVDR, CAPON

% PHYSICAL CONCEPT: feed_permittivity and feed_d represent the physical characteristics
% of the antenna feeding structure. Microwaves travel slower through the feed,
% adding an extra fixed time delay before reaching the breast boundary.
feed_permittivity = 1;
feed_d = 15e-3; % CP=15 % LP = 21
gap    = 2e-3;  % gap = 2.7158e-3; (disabled)

% -------------------------------
% Frequency Range
% -------------------------------
f_start = 1e9;
f_end   = 4e9;
freq_step = 1;

[scan2, scan1, frequencies, sensors_locations, channel_names] = load_data_asu(data, conf_pol, channels_mode);
scan2 = mimt.manage_data.scale_reflections(scan2, channel_names, scale_factor);
scan1 = mimt.manage_data.scale_reflections(scan1, channel_names, scale_factor);
params.scan2                    = scan2;
params.scan1                    = scan1;
params.frequencies              = frequencies;
params.sensors_locations        = sensors_locations;
params.channel_names            = channel_names;
params.f_start                  = f_start;
params.f_end                    = f_end;
params.freq_step                = freq_step;
params.ROI                      = ROI;
params.slice                    = slice;
params.resolution               = resolution;
params.relative_permittivity    = relative_permittivity;
params.signal_threshold         = signal_threshold;
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
%% beamform
[img, tumor_x, tumor_y] = mimt.process.compute_beamform(params);
%%
% saveas(gcf, './ain_shams/results/simulation/2/RC2.png');