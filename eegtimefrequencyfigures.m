%{
Luke Vargas 07/26/2024
This program is set to loop for a set amount of times as chosen by the
individual running the code. be sure to change the the appropriate paths,
variable names, and numbers.
This program is for post preprocess. The purpose is to plot time frequency
for the set channels denoted by the user under the array "labels". Channels
may be removed due to noisiness/ being unfit for data. Rather than
interpolating the channels, the program will search for the channels in the
EEG struct under EEG.chanloc and store the field value associated with the
channel under the fields struct. After cataloging the avaialble channels
with the corresponding field number, the program will loop to plot time
frequency.

%}

%global variables
datapath = 'C:\Path\to\the\.vhdrfiles\';
TFimagefolder = 'C:\Path\to\desired\output\image\folder\';
    labels = {'FT7', 'FC5', 'FC3', 'T7', 'C5', 'C3', 'TP7', 'CP5', 'CP3'}; %change and add labels as necessary for plot

%loop for the amount of trials, e.g., 4 avaialble trials so trialNum = 1:4
for trialNum = 1:6

    %local variables for datasets
    trialSetvarGoEpochs = sprintf('trial%d_0712_goepochs.set', trialNum);
    trialSetvarNoGoEpochs = sprintf('trial%d_0712_nogoepochs.set', trialNum);

    %note that the amount of tfgraphs for go and nogo should be the same
    %for each trial i.e. trial 1 nogo and go epochs should have same amount
    %of tfgraphs

    %load go epoch set
    EEG = pop_loadset(trialSetvarGoEpochs, datapath);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', trialSetvarGoEpochs, 'gui', 'off');
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    %call tfplot function
    tfplot(EEG,labels,trialNum,TFimagefolder,'GoEpochs');

    %load nogo epoch set
    EEG = pop_loadset(trialSetvarNoGoEpochs, datapath);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', trialSetvarNoGoEpochs, 'gui', 'off');
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    %call tfplot function
    tfplot(EEG,labels,trialNum,TFimagefolder,'NoGoEpochs');
end

%tfplot function used to plot the tf response for each avaialble channel
%denoted in "labels"
function tfplot(EEG,labels,trialNum,TFimagefolder,Epoch)

%declare new struct to store fields number 
fields = struct();
    for i = 1:length(labels) %loops determined by label array
        label = labels{i};
        found = false; %declares found as false initially
        
        %label search in EEG locs
        for j = 1:length(EEG.chanlocs)
        if strcmp(EEG.chanlocs(j).labels, label)
        fields.(label) = j; %store the field value
        found = true;
        break;
        end
        end
        
        %if the channel is not found, print a message and skip it
        if ~found
        fprintf('Channel %s removed due to noise.\n', label);
        end
    end

    %plot channels found from the fields struct
    channels = fieldnames(fields);
    for i = 1:length(channels)
    channel = channels{i}
    field_value = fields.(channel);

    fig = figure; %declares fig as figure var
    pop_newtimef( EEG, 1, field_value, [-5000  5000], [3         0.8] , 'topovec', field_value, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', channel, 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 10240);

     % figure save to set path
    ImageName = sprintf('trial%d_%s_%s_TF.png', trialNum, channel, Epoch);
    outputImagePath = fullfile(TFimagefolder, ImageName);
    fprintf('Saving figure: %s\n', outputImagePath); %debuggy
    saveas(fig, outputImagePath); % Save as PNG file
    close(fig); %closes fig automatically. you can comment this line out if you want to keep the files open
    end
    
end
