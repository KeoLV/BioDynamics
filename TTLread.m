%Luke Vargas 7/29/2024 simple TTL plotter for BioDynamics Lab

%path to csvFolder
csvFolderpath = 'C:\Path\to\your\.csvfolder\';
outputImageFolderPath = 'C:\Path\to\your\desired\output\image\folder\s';
for trialNum = 1:6

%local variables for datasets
TTLdata = sprintf('trial%d_TTL_0712.csv', trialNum);
csvFilePath = fullfile(csvFolderpath, TTLdata);
%read the data from the CSV file
data = readmatrix(csvFilePath);
%extract time from the second column
time = data(:, 2);

%extract EMG signals from the third and fourth columns
ttl_signal1 = data(:, 3);

fig = figure;

%plot EMG Signal 1
subplot(2, 1, 1);
plot(time, ttl_signal1, 'b');
xlabel('Time (s)');
ylabel('TTL Channel 1');
title(['TTL Channel 1 from ', TTLdata]);
grid on;

    %save the figure
    outputImage = sprintf('trial%d_TTL_0712_figure.png', trialNum);
    outputImagePath = fullfile(outputImageFolderPath, outputImage);
    saveas(fig, outputImagePath); %save as PNG file
    
    close(fig);

end