BioDynamics Parkinsons Adjacent Research

This git contains .m or MATLAB files

## Installation
This project requires EEGLAB + MATLAB to be installed and updated on your computer

## Usage
EEG:

After gathering EEG data, sort your data into the appropriate files. 
First run eegpreprocess.m, this program loops based on the amount of files in a set folder, based on your determined datapath
Run eegtimefrequencyfigures to generate figures for corresponding trials.

EMG:

EMG files still in development
Run emgcsvadj to adjust EMG .csv file to correspond time "0" with first stimulus or high from TTL (first value above 1)
Run emgtoeegset to take adjusted EMG file, and import it to EEG software. This also adds the events from the corresponding 
  eeg file and sets the first TTL signal of 's2'or when the program starts, as the beginning of the new set to match the
  stimulus events with the emg response signals
Run emgepochfigures to epoch around go and no go signals, remove the baseline, and generate the average graphs - still under development


## License
Osaka University
This project is developed as part of research at Osaka University. 
Any use of this software should acknowledge Osaka University and the BioDynamics Parkinsons Adjacent Research project.

This project uses EEGLAB and MATLAB, which have their own licensing requirements. Users must ensure they comply with the licenses for these tools.
