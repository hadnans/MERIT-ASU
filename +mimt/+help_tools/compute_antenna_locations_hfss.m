% z = 20;
% ROI = 70;
% feed_length = 0;
% num_of_sensors = 10;
% distance = sqrt(ROI^2 - z^2); % point in the phantom surface 
% % distance = ROI + feed_length;
% 
% idx = 1;
% antenna_locations = zeros(num_of_sensors, 3);
% 
% for angle = 0:360/num_of_sensors:((1-1/num_of_sensors)*360)
%     x = distance * cos(deg2rad(angle));
%     y = distance * sin(deg2rad(angle));
%     if abs(x) < 0.001
%         x = 0;
%     end
%     if abs(y) < 0.001
%         y = 0;
%     end
%     antenna_locations(idx, :) = [x; y; z];
%     idx = idx + 1;
% end
% writematrix(antenna_locations, './al_azhar/hfss_data/10_sensors/sensors_locations.csv');

% z = 20;
ROI = 71;
feed_length = 0;
distance = ROI + feed_length;
num_of_sensors = 8;

idx = 1;
antenna_locations = zeros(num_of_sensors, 3);
z = distance * sin(deg2rad(15));
distance = distance * cos(deg2rad(15));

for angle = 0:360/(num_of_sensors/2):((1-1/(num_of_sensors/2))*360)
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
distance = ROI + feed_length;
z = distance * sin(deg2rad((90-15)/2+15));
distance = distance * cos(deg2rad((90-15)/2+15));

for angle = 45:90:(360-45)
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
writematrix(antenna_locations, './al_azhar/hfss_data/8_sensors/sensors_locations.csv');