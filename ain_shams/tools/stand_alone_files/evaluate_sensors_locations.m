function sensors_locations = evaluate_sensors_locations(ROI, cross_angle, sensor_height, phantom_height)
    first_plane_radius = ROI;
    second_plane_XY = ROI * cos(cross_angle) * 1.2;
    second_plane_Z = ROI * sin(cross_angle);
    sensors_locations = zeros(9, 3);
    sensors_locations(1,:) = [0;0;phantom_height];
    sensors_locations(2,:) = [0;-first_plane_radius;sensor_height];
    sensors_locations(3,:) = [first_plane_radius;0;sensor_height];
    sensors_locations(4,:) = [0;first_plane_radius;sensor_height];
    sensors_locations(5,:) = [-first_plane_radius;0;sensor_height];
    sensors_locations(6,:) = [second_plane_XY;0;second_plane_Z];
    sensors_locations(7,:) = [0;-second_plane_XY;second_plane_Z];
    sensors_locations(8,:) = [-second_plane_XY;0;second_plane_Z];
    sensors_locations(9,:) = [0;second_plane_XY;second_plane_Z];
end