function display_3d(img, points, antenna_locations, threshold)
  
    valid = img > threshold;       
    marker_sizes = 100 * img(valid);  
    
    scatter3(points(valid,1), points(valid,2), points(valid,3), ...
             marker_sizes, img(valid), 'filled', 'MarkerFaceAlpha', 0.5);
    hold on;
    
    scatter3(antenna_locations(:,1), antenna_locations(:,2), antenna_locations(:,3), ...
             300, 'red', 'filled', 'diamond', 's');
    for i = 1:size(antenna_locations, 1)
        text(antenna_locations(i,1), antenna_locations(i,2), antenna_locations(i,3), ...
             sprintf('A%d', i), 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold');
    end

    axis equal; grid on;
    xlabel('X (mm)'); ylabel('Y (mm)');zlabel('Z(mm)');
    % title('3d - one tumor');
    view(45, 45);
end
