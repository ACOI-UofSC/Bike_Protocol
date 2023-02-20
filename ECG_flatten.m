epoch=1;
names_both;   %gets names of data file

%ECG
delimiterIn = ' ';
headerlinesIn =1;   
A = importdata(filename_ECG,delimiterIn,headerlinesIn);

import_line=2;                          %row that you want to start analyzing from or STARTING POINT

t_ECG=transpose(A.data(1+trial_start*fs_ECG:trial_length*fs_ECG,2));% setting up the time variable, column is second number
ECG=transpose(A.data(1+trial_start*fs_ECG:trial_length*fs_ECG,4)); %raw filtered ecg trace in column given by second number, 4
ECG=fillmissing(ECG, 'previous');



dt_ECG=1/fs_ECG;            %sampling time
samples_ECG=round((epoch)/dt_ECG);   %number of samples for the epoch window
t_ECG=t_ECG/fs_ECG;         %convert samples
t_ECG=t_ECG-t_ECG(1);       %reset start to zero

% ECG_filt=lowpass(ECG,3,fs_ECG,'ImpulseResponse','iir','Steepness',0.8);%high pass filter to eliminate motion artefacts and other slow processes 
% ECG_filt=conv(ECG_filt, exp(-t_ECG/0.25).*heaviside(t_ECG));
% ECG_filt=ECG_filt(1:length(ECG));
ECG_filt=ECG-movmean(ECG, 50); %remove motion artefact
ECG_trend=movmax((ECG_filt), samples_ECG);

ECG_flat=ECG_filt./ECG_trend;  %normalize and flatten

[m_ECG,I_ECG]=findpeaks(ECG_flat.*(ECG_flat>0.6));
% plot(t_ECG, ECG_trend, t_ECG, ECG_filt)
figure
plot(t_ECG, ECG_flat)
hold on
scatter(t_ECG(I_ECG),m_ECG)  %plot peak
ylim([-2 2])

%calculate time domain HR
HR_flat_ECG=(60./[diff(t_ECG(I_ECG)),1]);
HR_flat_ECG=filloutliers(HR_flat_ECG, 'previous','movmedian',40);
% HR_flat_ECG=filloutliers(HR_flat_ECG, 'previous');

HR_flat_ECG=movmean(HR_flat_ECG,40);  

figure
plot(t_ECG(I_ECG),HR_flat_ECG)