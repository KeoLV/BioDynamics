
%Luke Vargas 7/29/2024 simple EMG plotter for BioDynamics Lab

%path to csvFolder
csvFolderpath = 'C:\Path\to\your\.csvfolder\';
outputImageFolderPath = 'C:\Path\to\your\desired\output\image\folder\s';

for trialNum = 1:6 %set "6" based on number of trials

%local variables for datasets
EMGdata = sprintf('trial%d_EMG_0712.csv', trialNum);
csvFilePath = fullfile(csvFolderpath, EMGdata);

%Read the data from the CSV file
data = readmatrix(csvFilePath);
%Extract time from the second column
time = data(:, 2);

%EMG signals stored in 3rd and 4th columns. Depending on EEG apparatus
%used, more or less EMG channels can be added
emg_signal1 = data(:, 3);
emg_signal2 = data(:, 4);
%emg_signal# = data(:, #);

fig = figure;

% Plot EMG Signal 1
subplot(2, 1, 1);
plot(time, emg_signal1, 'b');
xlabel('Time (s)');
ylabel('EMG Signal 1');
title(['EMG Signal 1 from ', EMGdata]);
grid on;

% Plot EMG Signal 2
subplot(2, 1, 2);
plot(time, emg_signal2, 'r');
xlabel('Time (s)');
ylabel('EMG Signal 2');
title(['EMG Signal 2 from ', EMGdata]);
grid on;

    %saves figure in outputfolder
    outputImage = sprintf('trial%d_EMG_0712_figure.png', trialNum);
    outputImagePath = fullfile(outputImageFolderPath, outputImage);
    saveas(fig, outputImagePath); % Save as PNG file
    
    %%closes fig automatically. you can comment this line out if you want to keep the files open
    close(fig);

end