z = 28;
antenna_length = 60;
ROI = 60;
distance = ROI + antenna_length;
idx = 1;
antenna_locations = zeros(24, 3);
for angle = 0:15:165
    x = distance * cos(angle*pi/180);
    y = distance * sin(angle*pi/180);
    if abs(x) < 0.001
        x = 0;
    end
    if abs(y) < 0.001
        y = 0;
    end
    antenna_locations(idx, :) = [x; y; z];
    idx = idx + 1;
end
phase = 180;
for angle = 0:15:165
    x = distance * cos((angle+phase)*pi/180);
    y = distance * sin((angle+phase)*pi/180);
    if abs(x) < 0.001
        x = 0;
    end
    if abs(y) < 0.001
        y = 0;
    end
    antenna_locations(idx, :) = [x; y; z];
    idx = idx + 1;
end

writematrix(antenna_locations, 'measured\antenna_locations.csv');