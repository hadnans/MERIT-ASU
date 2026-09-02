%% scan2 vs scan1 db
figure;
subplot(2,1,2);plot(frequencies, mag2db(abs(scan1)));xlabel('Frequency (GHz)');ylabel('Signals Magnitude (dB)');title('no tumor');
yline(-10, 'r--', 'Threshold');  
subplot(2,1,1);plot(frequencies, mag2db(abs(scan2)));xlabel('Frequency (GHz)');ylabel('Signals Magnitude (dB)');title('tumor');
yline(-10, 'r--', 'Threshold');  

%% scan2 vs scan1 mag
figure;
subplot(3,1,3);plot(frequencies, (abs(scan2 - scan1)));xlabel('Frequency (GHz)');ylabel('Signals Magnitude');title('diff');
subplot(3,1,2);plot(frequencies, (abs(scan1)));xlabel('Frequency (GHz)');ylabel('Signals Magnitude');title('no tumor');
subplot(3,1,1);plot(frequencies, (abs(scan2)));xlabel('Frequency (GHz)');ylabel('Signals Magnitude');title('tumor');

%% scan2 vs scan1 phase
figure;
subplot(2,1,2);plot(frequencies, (angle(scan1)));xlabel('Frequency (GHz)');ylabel('Signals phase');title('no tumor');
subplot(2,1,1);plot(frequencies, (angle(scan2)));xlabel('Frequency (GHz)');ylabel('Signals phase');title('tumor');
%% certain channel
figure;
tx = 2;
rx = 3;
signal_idx = find(channel_names(:,1) == tx & channel_names(:,2) == rx);
signal = scan2(:, signal_idx);
subplot(3,1,1);plot(frequencies, mag2db(abs(signal)));xlabel('Frequency (GHz)');ylabel('Signal Magnitude');title('dB');
subplot(3,1,2);plot(frequencies, abs(signal));xlabel('Frequency (GHz)');ylabel('Signal Magnitude');title('|abs|');
subplot(3,1,3);plot(frequencies, angle(signal));xlabel('Frequency (GHz)');ylabel('Signal Phase');title('rad');

%% frequency x channel x data value
freqs = frequencies / 1e9;
channels = 1:size(scan2, 2);
[CH, FREQ] = meshgrid(channels, freqs);

data = scan2;

figure;
surf(CH, FREQ, abs(data), 'EdgeColor', 'none');
xlabel('Channel Index');
ylabel('Frequency (GHz)');
zlabel('|S|');
title('S-Parameters (Magnitude)');
colormap turbo; colorbar;
view(45, 30);

%% plot no tumor vs tumor time domain 
figure;
df = frequencies(2) - frequencies(1);
T = 1/df;
dt = 1/(2*frequencies(end));
time_axis = 0:dt:T;
signal_time_no_tumor = merit.process.fd2td(scan1, frequencies, time_axis);
signal_time_tumor = merit.process.fd2td(scan2, frequencies, time_axis);

subplot(3,1,3);plot(time_axis, (signal_time_no_tumor));xlabel('time (s)');ylabel('Signals Magnitude');title('no tumor');
subplot(3,1,2);plot(time_axis, (signal_time_tumor));xlabel('time (s)');ylabel('Signals Magnitude');title('tumor');
subplot(3,1,1);plot(time_axis, (signal_time_tumor - signal_time_no_tumor));xlabel('time (s)');ylabel('Signals Magnitude');title('difference');

%% validate merit.process.fd2td
figure;
df = frequencies(2) - frequencies(1);
T = 1/df;
dt = 1/(2*frequencies(end));
time_axis = 0:dt:T;
signal = merit.process.fd2td(scan2, frequencies, time_axis);
subplot(2,1,2);plot(frequencies, mag2db(abs(scan2)));xlabel('Frequency (GHz)');ylabel('Signals Magnitude (dB)');title('before fd2td');
signal = merit.process.td2fd(signal, time_axis, frequencies);
subplot(2,1,1);plot(frequencies, mag2db(abs(signal)));xlabel('Frequency (GHz)');ylabel('Signals Magnitude (dB)');title('after fd2td');
%% test clutter removal
df = frequencies(2) - frequencies(1);
T = 1/df;
dt = 1/(2*frequencies(end));
time_axis = 0:dt:T;
signal_time_tumor = merit.process.fd2td(scan2, frequencies, time_axis);
signal_time_gating = time_gating(signal_time_tumor, 10);
signal_time_avg = average_subtraction(signal_time_tumor);
signal_time_no_tumor = merit.process.fd2td(scan1, frequencies, time_axis);

subplot(4,1,1);plot(time_axis, (signal_time_tumor));xlabel('time (s)');ylabel('Signals Magnitude');title('Raw');
subplot(4,1,3);plot(time_axis, (signal_time_avg));xlabel('time (s)');ylabel('Signals Magnitude');title('Average Subtraction');
subplot(4,1,2);plot(time_axis, (signal_time_gating));xlabel('time (s)');ylabel('Signals Magnitude');title('Time Gating');
subplot(4,1,4);plot(time_axis, (signal_time_tumor - signal_time_no_tumor));xlabel('time (s)');ylabel('Signals Magnitude');title('Background Subtraction');