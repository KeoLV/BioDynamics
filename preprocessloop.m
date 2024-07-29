%{
 Luke Vargas 07/24/2024
 This program is set to loop for a set amount of times as chosen by the
 individual running the code. be sure to change the the appropriate paths,
 variable names, and numbers.
%}
% Define the path for data
datapath = 'C:\Path\to\your\.vhdrfiles\';

    %initialize EEG
    [ALLEEG, EEG, CURRENTSET] = eeglab;

% Loop through each trial
for trialNum = 1:3
    %Creating trial specific names for each loop iteration
    trialFilename = sprintf('trial%d_0723.vhdr', trialNum);
    trialSetname = sprintf('trial%d_0723', trialNum);
    trialSetnameICA = sprintf('trial%d_0723_icaonly.set', trialNum);
    trialSetnameGoEpochs = sprintf('trial%d_0723_goepochs.set', trialNum);
    trialSetnameNoGoEpochs = sprintf('trial%d_0723_nogoepochs.set', trialNum);
    
    %load trial data
    EEG = pop_loadbv(datapath, trialFilename, [], [1:64]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', trialSetname, 'gui', 'off');
    
    %edit channel location/add dipfit standard 1005 model, and optimize
    %center location
    EEG=pop_chanedit(EEG, 'lookup','C:\Path\to\your\.elc files');
    EEG=pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[]);');
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

    
    %HPF 1 to 60
    EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',60);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
    
    %removal of channels with HF standard deviation more than 6, and a correlation among nearby channels less than 0.5 (from standrd of 4 and 0.8 respectively)
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',20,'ChannelCriterion',0.5,'LineNoiseCriterion',6,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
    
    %run ica and save
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'rndreset','yes','interrupt','on');
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_saveset( EEG, 'filename',trialSetnameICA,'filepath',datapath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    %extract epochs for Go
    EEG = pop_epoch( EEG, {  's8'  }, [-5  5], 'newname', sprintf('%s_goepochs', trialSetname), 'epochinfo','yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'savenew', fullfile(datapath, trialSetnameGoEpochs),'gui','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',3,'study',0); 

    %extract epochs for NoGo
    EEG = pop_epoch( EEG, {  's16'  }, [-5  5], 'newname', sprintf('%s_nogoepochs', trialSetname), 'epochinfo','yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'savenew', fullfile(datapath, trialSetnameNoGoEpochs),'gui','off');
    
    % Redraw EEGLAB GUI
    eeglab redraw;
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG = []; CURRENTSET = [];
end

% Clear variables

