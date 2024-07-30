%{Luke Vargas 07/29/2024
% This program takes a .csv file for emg and adjusts it based on the TTL
% criteria. Upon encountering first stimulus in TTL, the program marks the
% time and sets it as the start of the corresponding EMG. Thus, the first 
% "high" delivered by TTL is found, and the time found before is removed 
% from the emg entirely}%
%path to the folders containing the TTL and EMG files
datapathcsv = 'C:\path\to\csvfolderwithemg&ttl\';
datapathoutput = 'C:\Users\Luke\Documents\MATLAB\eeglab_current\eeglab2024.0\csvFolder\0723fix';

%loop through files named trialX_TTL_0712.csv and trialX_EMG_0712.csv; X
%ranges from 1 to # of determined trials
for trialNum = 1:4 %adjust the number based on the actual number of trials

    %file names for the current trial of loop
    TTLcurrent = sprintf('trial%d_TTL_0723.csv', trialNum);
    EMGcurrent = sprintf('trial%d_EMG_0723.csv', trialNum);

    %paths
    TTLfile = fullfile(pathtocsv, TTLcurrent);
    EMGfile = fullfile(pathtocsv, EMGcurrent);
    TTLdata = readmatrix(TTLfile);
    EMGdata = readmatrix(EMGfile);
    
    %find the first value > 1 in column 3 of TTL data, logic dictates
    %numbers are only between <1 and >4
    idx = find(TTLdata(:,3) > 1,1,'first');
    
    %take the corresponding time value from column 2
    TTLtime = TTLdata(idx,2);
    
    %find the first index in EMG data where the time is greater than or equal to TTLtime
    startIndex = find(EMGdata(:,2) >= TTLtime,1,'first');
    %extract
    adjEMGdata = EMGdata(startIndex:end, :);
    
    %adjust the frame numbers and time values to start from zero
    adjEMGdata(:,1) = adjEMGdata(:,1) - adjEMGdata(1,1);
    adjEMGdata(:,2) = adjEMGdata(:,2) - adjEMGdata(1,2);
    
    %save the adjusted EMG data to a new CSV file
    adjdata = sprintf('trial%d_EMG_0723_adjusted.csv', trialNum);
    adjdatapath = fullfile(pathtooutput, adjdata);
    writematrix(adjEMGdata, adjdatapath);

end
