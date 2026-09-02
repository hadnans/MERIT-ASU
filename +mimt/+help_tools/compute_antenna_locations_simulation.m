z = 20;
ROI = 70;
distance = sqrt(ROI^2 - z^2); % point in the phantom surface 
idx = 1;
antenna_locations = zeros(9, 3);

for angle = 0:45:315
    x = distance * cos(deg2rad(angle));
    y = distance * sin(deg2rad(angle));
    if abs(x) < 0.001
        x = 0;
    end
    if abs(y) < 0.001
        y = 0;
    end
    antenna_locations(idx, :) = [x; y; z];
    idx = idx + 1;
end
antenna_locations(9, :) = [0, 0, ROI];

writematrix(antenna_locations, './al_azhar/cst_data/9_round/sensors_locations.csv');