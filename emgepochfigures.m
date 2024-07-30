%Luke Vargas 7/30/2024
%epoch figure generator from emg. takes emg set files 
%path to adj figures from emgtoeegset
datapathin = 'C:\path\to\input\data';
datapathout = 'C:\path\to\output\folder';

%initialize EEGLAB
[ALLEEG,EEG,CURRENTSET] = eeglab;

%loop through files for each trial
for trialNum = 1:4 %adjust this number based on range of number of trials
    inputFilevar = sprintf('trial%d_EMG_0723_with_events.set', trialNum);
    outputFilevarGo = sprintf('trial%d_EMG_0723_go_epochs.png', trialNum);
    outputFilevarNo = sprintf('trial%d_EMG_0723_nogo_epochs.png', trialNum);

    %load
    EMG = pop_loadset('filename', inputFilevar, 'filepath', datapathin);
    %filter
    EMG = pop_eegfiltnew(EMG, 20, 450);

    %full-wave rectification
    EMG.data = abs(EMG.data);

    %extract epochs around s8 events
    GoEpochs = pop_epoch(EMG, {'s8'}, [-1 1], 'epochinfo', 'yes');
    GoEpochs = pop_rmbase(GoEpochs, [-200 0]); %remove baseline

    %compute the average of the epochs for s8
    GoAverage = mean(GoEpochs.data, 3);

    %plot the average epochs for Go/s8
    figgo = figure;
    plot(GoEpochs.times, GoAverage);
    hold on;
    plot([0 0], ylim, 'k--'); % Add a vertical line at time 0
    title(sprintf('Average EMG Epochs Around s8 - Trial %d', trialNum));
    xlabel('Time (ms)');
    ylabel('Amplitude');
    saveas(figgo, fullfile(datapathout, outputFilevarGo));
    close(figgo);

    %extract epochs around s16/nogo events
    nogoEpochs = pop_epoch(EMG, {'s16'}, [-1 1], 'epochinfo', 'yes');
    nogoEpochs = pop_rmbase(nogoEpochs, [-200 0]); %remove baseline

    %average of the epochs for nogo
    s16Average = mean(nogoEpochs.data, 3);

    %plot the average epochs for nogo
    figno = figure;
    plot(nogoEpochs.times, s16Average);
    hold on;
    plot([0 0], ylim, 'k--');
    title(sprintf('Average EMG Epochs Around s16 - Trial %d', trialNum));
    xlabel('Time (ms)');
    ylabel('Amplitude');
    saveas(figno, fullfile(datapathout, outputFilevarNo));
    close(figno);
end
