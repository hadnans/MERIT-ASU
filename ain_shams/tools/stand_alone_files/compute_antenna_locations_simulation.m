% Cross
z = 20;
ROI = 75;
distance = sqrt(ROI^2 - z^2); % point in the phantom surface 
% distance = ROI; % point in the phantom surface 
idx = 1;
antenna_locations = zeros(9, 3);
step = 90;

for angle = 0:step:(360-step)
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
z = 55;
distance = sqrt(ROI^2 - z^2); % point in the phantom surface 
for angle = 0:step:(360-step)
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

writematrix(antenna_locations, 'ain_shams\9_sensors\data\phantom150\antenna_locations_C.csv');
%% Round 

z = 20;
ROI = 75;
% distance = sqrt(ROI^2 - z^2); % point in the phantom surface 
distance = ROI; % point in the phantom surface 
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

writematrix(antenna_locations, 'ain_shams\9_sensors\data\phantom150\antenna_locations_R.csv');