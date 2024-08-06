%{
Luke Vargas 08/06/2024
Time Frequnecy Stats
%}
%datapaths
inpath = 'C:\Users\Luke\Documents\MATLAB\eeglab2024.0\MASTER\epochfin\eeg\NormalGo\';
outpath = 'C:\Users\Luke\Documents\MATLAB\eeglab2024.0\MASTER\figures\test\test2\';
filelist = dir(fullfile(inpath, '*.set')); %creates a list of the .set input files

%variables
%poststim period
tstart = 0;
tend = 2500;
high = 2;%high/low ERSP thresholds (dB)
low = -2; 
freqbands = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'};
freqranges = [1 4; 4 8; 8 12; 12 30; 30 50];

%initialize EEGLAB
[ALLEEG EEG CURRENTSET] = eeglab;
exptype = ['Normal Go']; %change this variable to suit your experiment file title
epochsum = []; %epoch array for storage and math
numfiles = 0;

for i = 1:length(filelist) %loop C3 epoch data collection
    setname = filelist(i).name;
    EEG = pop_loadset('filename', setname, 'filepath', inpath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    %find index for C3
    c3index = find(strcmp({EEG.chanlocs.labels}, 'C3'));
    epochdata = EEG.data(c3index, :, :); %extract C3 data
    allepoch = epochdata;
    allepoch = allepoch + epochdata;
    numfiles = numfiles + 1; %increment file count

end

%calculate the average epoch data across trials
epochav = allepoch / numfiles;
%EEG struct for averaged data
EEGav = EEG;
EEGav.data = epochav;
EEGav.pnts = size(epochav, 2);
EEGav.trials = 1;

%time frequency decomposition
[ersp,itc,powbase,times,freqs,erspboot,itcboot] = pop_newtimef(EEGav, 1, 1, [-5000 5000], [3 0.8],'topovec', 1, 'elocs', EEGav.chanlocs,'chaninfo', EEGav.chaninfo, 'caption', caption_text,'baseline', [0], 'plotitc', 'off', 'plotersp', 'off','plotphase', 'off', 'padratio', 1, 'winsize', 2048);

%find indices 
[~, tstartidx] = min(abs(times - tstart));
[~, tendidx] = min(abs(times - tend));

%extract ERSP data post stimulus
erspsegment = ersp(:, tstartidx:tendidx);
highersp = erspsegment > high;
lowersp = erspsegment < low;
totalpoints = numel(erspsegment);
highersppercentage = sum(highersp(:)) / totalpoints * 100;
lowersppercentage = sum(lowersp(:)) / totalpoints * 100;
highfreq = freqs(any(highersp, 2));
lowfreq = freqs(any(lowersp, 2));

%storage for averaged ERSP values and percentage changes
aversp = zeros(length(freqbands), 1);
percentagechanges = zeros(length(freqbands), 1);

for f = 1:length(freqbands)
    %find frequency indices for the current band
    freqidx = freqs >= freqranges(f, 1) & freqs <= freqranges(f, 2);
    %mean within band and baseline
    aversp(f) = mean(mean(erspsegment(freqidx, :), 1), 2);
    baselinepower = mean(mean(powbase(freqidx))); % Average baseline power
    percentagechanges(f) = ((aversp(f) - baselinepower) / baselinepower) * 100;
end

%max and min ERSP values and corresponding times and frequencies
[maxersp, maxidx] = max(erspsegment(:));
[minersp, minidx] = min(erspsegment(:));
[maxfreq, maxtimeidx] = ind2sub(size(erspsegment), maxidx);
[minfreq, mintimeidx] = ind2sub(size(erspsegment), minidx);

peakamp = maxersp;
peaktime = times(tstartidx + maxtimeidx - 1);
peakfreq = freqs(maxfreq);
lowestamp = minersp;
lowesttime = times(tstartidx + mintimeidx - 1);
lowestfreq = freqs(minfreq);

%results to the text file
outputname = fullfile(outpath, sprintf('%s_ERSPstats.txt', exptype));
fid = fopen(outputname, 'w');
fprintf(fid, 'High ERSP percentage: %.2f%%\n', highersppercentage);
fprintf(fid, 'Low ERSP percentage: %.2f%%\n', lowersppercentage);
for f = 1:length(freqbands)
    fprintf(fid, '%s: %.2f dB, %.2f%% change\n', freqbands{f}, aversp(f), percentagechanges(f));
end
fprintf(fid, 'Peak ERSP Amplitude: %.2f dB at %.2f ms, %.2f Hz\n',peakamp, peaktime, peakfreq);
fprintf(fid, 'Lowest ERSP Amplitude: %.2f dB at %.2f ms, %.2f Hz\n',lowestamp, lowesttime, lowestfreq);
fclose(fid);
