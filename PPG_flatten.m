%Import Ben's PPG file
epoch=1;       %epoch length in seconds

names_both;   %gets names of data file


%PPG
delimiterIn = ' ';
headerlinesIn =1;   
A = importdata(filename_PPG,delimiterIn,headerlinesIn);

import_line=2;                          %row that you want to start analyzing from or STARTING POINT


PPG=transpose(A.data(1+round(trial_start*fs_PPG):round(trial_length*fs_PPG),3)); %raw PPG trace in column given by second number, 3
PPG=fillmissing(PPG, 'previous');
PPG=PPG-movmean(PPG, 30);


%dt=(t_PPG(end)-t_PPG(1))/length(t_PPG); %sampling frequency
samples_PPG=round((epoch)*fs_PPG);   %number of samples for the epoch window
t_PPG=(1/fs_PPG)*[1:1:length(PPG)];  %set up time

%PPG

PPG_filt=highpass(PPG,0.8,fs_PPG,'ImpulseResponse','iir','Steepness',0.5);%high pass filter to eliminate motion artefacts and other slow processes 
PPG_filt=lowpass(PPG_filt,3,fs_PPG,'ImpulseResponse','iir','Steepness',0.8);%low pass filter to eliminate motion artefacts and other slow processes 


PPG_trend=movmax(abs(PPG_filt), samples_PPG);

PPG_flat=PPG_filt./PPG_trend;  %normalize and flatten

[m,I]=findpeaks(PPG_flat.*(PPG_flat>0.5));
plot(t_PPG, PPG_trend, t_PPG, PPG_filt)
plot(t_PPG, PPG_flat)
hold on
scatter(t_PPG(I), PPG_flat(I))  %plot peak
ylim([-2 2])

%calculate time domain HR
HR_flat=(60./[diff(t_PPG(I)),1]);
HR_flat=filloutliers(HR_flat, 'previous','movmedian',40);
% HR_flat=filloutliers(HR_flat, 'previous');
% HR_flat=filloutliers(HR_flat, 'previous');
HR_flat=movmean(HR_flat,40);  

figure
plot(t_PPG(I),HR_flat)

% figure
% histfit(HR_flat)
% pd=fitdist(transpose(HR_flat),'Normal')  %fit the histogram of HR with normal distribution

%find breaths
% breath=HR_flat./movmean(HR_flat, 10);
% [height, time_index]=findpeaks(breath);
% 
% figure
% plot(t_PPG(I),(HR_flat./movmean(HR_flat, 10)))
% hold on
% scatter(t_PPG(I(time_index)),height)
    


