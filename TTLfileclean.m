%Luke Vargas 7/29/2024 simple TTL high finder for BioDynamics Lab
csvFolderpath = 'C:\Path\to\your\.csvfolder\';
outputFolderPath = 'C:\Path\to\your\desired\output\image\folder\s';

%loops through files named trialX_TTL_0712.csv where X ranges from 0 to 6
for trialNum = 1:6 %change 6 based on trial amount

    fileName = sprintf('trial%d_TTL_0712.csv', trialNum);
    %full path for current .csv file
    csvFilePath = fullfile(csvFolderPath, fileName);
    
    %read csv data
    data = readmatrix(csvFilePath);
    
    %array initialize
    events = [];
    
    %this loop keeps values >2
    i = 1;
    while i <= size(data, 1)
        %finds the first value > 2 in column 3 from the current position
        idx = find(data(i:end, 3) > 2, 1, 'first');
        
        if isempty(idx)
            break;
        end
        
        %adjusts the index to be relative to the whole dataset
        idx = idx + i - 1;
        
        %stores the row corresponding to the found value
        events = [events; data(idx, :)];
        
        %move to the next position, 2000 rows down, or 2 seconds (based on
        % sampling rate)
        i = idx + 2000;
    end
    
    %if more than 100 rows, take only the first 100 (based on amount of TTL
    %signals)
    if size(events, 1) > 100
        events = events(1:100, :);
    end
    
    %save the processed data to a new .csv file
    outputFileName = sprintf('trial%d_TTL_0712_events.csv', trialNum);
    outputFilePath = fullfile(outputFolderPath, outputFileName);
    writematrix(events, outputFilePath);
    
    fprintf('Processed file saved as %s\n', outputFileName);
end