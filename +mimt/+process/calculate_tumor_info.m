function [x0_mm, y0_mm, avg_radius_mm] = calculate_tumor_info(points, img, slice, tol, threshold_ratio)
%CALCULATE_TUMOR_RADIUS Estimates tumor center and average radius in a 2D slice.
%   Automatically adjusts ROI based on spatial grid spacing.

    % Get 2D slice
    idx = abs(points(:, 3) - slice) < tol;
    xy_slice = points(idx, :);
    xy_img   = img(idx);

    if isempty(xy_slice)
        x0_mm = 0; y0_mm = 0; avg_radius_mm = 0;
        return;
    end

    % Estimate grid spacing (assumes regular grid)
    unique_x = unique(xy_slice(:,1));
    unique_y = unique(xy_slice(:,2));
    dx = mean(diff(unique_x));
    dy = mean(diff(unique_y));
    grid_spacing = mean([dx, dy]);

    % Adaptive ROI = 15 × grid spacing (~covers tumor of ~3–5 cm depending on resolution)
    roi_size = 15 * grid_spacing;

    % Find peak
    [~, max_idx] = max(xy_img);
    peak_point = xy_slice(max_idx, :);   % [x0, y0, z0]
    x0 = peak_point(1);
    y0 = peak_point(2);
    max_val = xy_img(max_idx);
    threshold = threshold_ratio * max_val;

    % Restrict to ROI around peak
    roi_idx = abs(xy_slice(:,1) - x0) <= roi_size & ...
              abs(xy_slice(:,2) - y0) <= roi_size;
    xy_slice = xy_slice(roi_idx, :);
    xy_img   = xy_img(roi_idx);

    % Get thresholded points
    x = xy_slice(:,1);
    y = xy_slice(:,2);
    val = xy_img;
    above_idx = val >= threshold;

    if ~any(above_idx)
        avg_radius_mm = 0;
        x0_mm = x0 * 1e3;
        y0_mm = y0 * 1e3;
        return;
    end

    % Compute radial distances from center
    x0_mm = x0 * 1e3;
    y0_mm = y0 * 1e3;
    x_mm  = x(above_idx) * 1e3;
    y_mm  = y(above_idx) * 1e3;

    distances = sqrt((x_mm - x0_mm).^2 + (y_mm - y0_mm).^2);
    avg_radius_mm = mean(distances); % average radius

    % Display
    fprintf('Tumor at x = %.2f mm, y = %.2f mm\n', x0_mm, y0_mm);
    fprintf('Average Tumor Radius = %.2f mm\n', avg_radius_mm);
end
