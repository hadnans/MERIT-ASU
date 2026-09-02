function display_2d(img, points, slice_axis, slice_position, resolution, pixel_size)

if nargin < 6
    pixel_size = 30;
end
    n = abs(points(:,slice_axis) - slice_position) < 1e-6; 
    slice_plane = points(n, :);
    c = img(n);

    if slice_axis == 1
        axis1 = 2; axis2 = 3;
        xlabel('Y (mm)'); ylabel('Z (mm)');
    elseif slice_axis == 2
        axis1 = 1; axis2 = 3;
        xlabel('X (mm)'); ylabel('Z (mm)');
    else
        axis1 = 1; axis2 = 2;
        xlabel('X (mm)'); ylabel('Y (mm)');
    end

    % Background square
    xmin = min(slice_plane(:,axis1))*1.1;
    xmax = max(slice_plane(:,axis1))*1.1;
    ymin = min(slice_plane(:,axis2))*1.1;
    ymax = max(slice_plane(:,axis2))*1.1;
    
    rectangle('Position',[xmin ymin xmax-xmin ymax-ymin], ...
              'FaceColor',[0.1 0 0.2], ...   
              'EdgeColor','none');       
    hold on;

    scatter(slice_plane(:,axis1), slice_plane(:,axis2), ...
        pixel_size * (resolution * 1e3) , c, 'filled');

    hold off;
    axis equal; grid on;
    % title('2D - one tumor');
end
