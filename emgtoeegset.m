%Luke Vargas 7/30/2024
%converts emg.csv files to eeglab.set files with the events from the
%matching trial. pretty cool
%folder paths
datapathEEG = 'C:\path\to\eeg.setfiles';
datapathCSV = 'C:\path\to\emg.csvfiles';
datapathout = 'C:\path\to\ze\outputfolder';
%sampling rates, change as necessary
eegSR = 2048;
emgSR = 1000;
%initialize EEGLAB
[ALLEEG,EEG,CURRENTSET] = eeglab;
%loop through files for each trial
for trialNum = 1:6 %adjust this number based on range of number of trials
   %file vars
    eegFilevar = sprintf('trial%d_0723_icaonly.set', trialNum);
    emgFilevar = sprintf('trial%d_EMG_0723_adjusted.csv', trialNum);
    outputFilevar = sprintf('trial%d_EMG_0723_with_events.set', trialNum);

    %load
    EEG = pop_loadset('filename', eegFilevar, 'filepath', datapathEEG);

    %read
    emgData = readmatrix(fullfile(datapathCSV, emgFilevar));
    
    %extract signals (columns 3/4) time (column 2)
    emgTime = emgData(:, 2);
    emgSig1 = emgData(:, 3);
    emgSig2 = emgData(:, 4);

    %new .set for EMG
    EMG = eeg_emptyset();
    EMG.data = [emgSig1'; emgSig2'];
    EMG.nbchan = size(EMG.data, 1);
    EMG.pnts = size(EMG.data, 2);
    EMG.srate = emgSR; %sets the EMG sampling rate
    EMG.xmin = emgTime(1) / 1000; %start time in seconds
    EMG.trials = 1;
    EMG.chanlocs = struct('labels', {'EMG1', 'EMG2'});
    EMG.setname = 'EMG data';

%copy events from corresponding trial
EMG.event = EEG.event;

%find the first 's2' event and its latency (time or its delay)
firstS2 = []; %initialize to store the latency of the first 's2' event
for i = 1:length(EMG.event)
    if strcmpi(EMG.event(i).type, 's2')
        firstS2 = (EMG.event(i).latency - 1) * (1000 / eegSR); %convert to milliseconds
        break;
    end
end

%shift events so first s2 becomes latency 2 or like frame 2
for i = 1:length(EMG.event)
    %convert EEG latency to milliseconds
    eegLatency2Ms = (EMG.event(i).latency - 1) * (1000 / eegSR); % Latency in ms
    %adjust latency by subtracting the first 's2' latency and adding 1 ms
    adjustedLatency2Ms = eegLatency2Ms - firstS2 + 1; % +1 to ensure starting from 2
    %convert latency from milliseconds to EMG sample points
    emgLatencyIndex = round((adjustedLatency2Ms / 1000) * emgSR); % Convert to EMG index
    EMG.event(i).latency = emgLatencyIndex + 1; % Ensure index starts from 1
end


    %save the new EEG dataset with EMG data and events
    pop_saveset(EMG, 'filename', outputFilevar, 'filepath', datapatout);
    fprintf('Processed and saved EMG file with events as %s\n', outputFilevar);
end
