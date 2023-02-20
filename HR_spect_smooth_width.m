%PPG_flatten; %time domain PPG HR from Systolic-Systolic spacing
%ECG_flatten; %time domain ECG HR R-R spacing
%HR_spect2;
close all

PPG_conv=PPG;

% PPG_conv=conv(PPG_flat,exp(-t_PPG/0.2).*heaviside(t_PPG));
% PPG_conv=PPG_conv(1:length(PPG));
% PPG_conv=movmean(PPG_conv, 10);

%filter motion artefact using notch filter
% Design a notch filter with a Q-factor of Q=3 to remove a 100BPM=50/60Hz tone from 
% system running at fs_PPG Hz.

start=770;   %starting point in seconds for notch filter to remove motion artefact
stop=1050;  %last point in seconds for notch filter 
f_motion=90; %frequency of motion artefact in BPM/RPM for notch filter
Wo=(f_motion/60)/(fs_PPG/2);
BW=Wo;
[b,a]=iirnotch(Wo, BW);
PPG_conv=filter(b,a, PPG_conv).*(t_PPG>=start).*(t_PPG<=stop)+PPG_conv.*(t_PPG<start)+PPG_conv.*(t_PPG>stop);
% 
start=770;   %starting point in seconds for notch filter to remove motion artefact
stop=1050;  %last point in seconds for notch filter 
f_motion=40; %frequency of motion artefact in BPM/RPM for notch filter
Wo=(f_motion/60)/(fs_PPG/2);
BW=Wo/2;
[b,a]=iirnotch(Wo, BW);
PPG_conv=filter(b,a, PPG_conv).*(t_PPG>=start).*(t_PPG<=stop)+PPG_conv.*(t_PPG<start)+PPG_conv.*(t_PPG>stop);


% PPG_conv=filter(b,a, PPG_conv).*(t_PPG>=start)+PPG_conv.*(t_PPG<start);

[p,f,t]=pspectrum(PPG_conv, fs_PPG, 'spectrogram','FrequencyLimits',[0 10],'TimeResolution',30);
% pspectrum(PPG_flat, fs_PPG, 'spectrogram','FrequencyLimits',[0 10], 'TimeResolution',20);
% hold on

% p=p.*BW;

x=1:1:length(t);    
p(:,x)=p(:,x)./max(p(:,x));

% [pks, idx]=max(p(:,x));

idx=x./x;
width=x./x;
[pk1, idx(1)]=max(p(:,1));
idx(1)=104;

for i=2:1:length(t)
[X, iX, wX]=findpeaks(p(:,i).*(p(:,i)>0.3));

[Xmin,iXmin]=min(abs(iX-idx(i-1)));
idx(i)=iX(iXmin);
%if jump is too big, keep previous value
idx(i)=iX(iXmin)*(abs(f(idx(i))-f(idx(i-1)))<=0.8)+idx(i-1)*(abs(f(idx(i))-f(idx(i-1)))>0.8);
width(i)=wX(iXmin);
end

HR_sp=60*f(idx);  %derivation of heart rate from peak frequency

%HR spectrogram calculation, with outliers removed and replaced
HR_sp_smooth=movmean(filloutliers(HR_sp,'spline','movmedian',20),1)';
HR_sp_smooth=interp1(t, HR_sp_smooth, t_PPG(I));  %HR_sp_smooth upsample to t_PPG x-axis

%error calcuation compared with time domain from PPG_flatten.m
HR_flat_err=interp1(t_PPG(I), HR_flat, t_PPG(I)); %resample back up to t_PPG x-axis
err=nanstd((HR_sp_smooth-HR_flat_err)./HR_flat_err) %error of PPG HR_sp wrt HR PPG from PPG_flatten
err_BPM=nanmean(abs((HR_sp_smooth-HR_flat_err)))

%taking only from frequency domain with smooth changes
HRPPG=HR_sp_smooth;

figure
scatter(t_PPG(I), HRPPG)
hold on
plot(t_PPG(I), HR_flat)



%cleaned up error against ECG time domain ground truth
figure
hold on
plot(t_PPG(I), HRPPG);
%interpolate/resample ECG HR back up to t_PPG x-axis
HRECG=interp1(t_ECG(I_ECG), HR_flat_ECG, t_PPG(I));
plot(t_PPG(I), HRECG)


rmserror_self_consistent=nanstd((HRPPG-HRECG)./HRECG)
rmserror_HR_sp=nanstd((HR_sp_smooth-HRECG)./HRECG)
rmserror_HR_sp_BPM=nanstd((HR_sp_smooth-HRECG))
self_consistency= sum(abs(HR_flat-HR_sp_smooth)<10)/length(HR_sp_smooth)
mean_abs_error =nanmean(abs((HR_sp_smooth-HRECG)./HR_sp_smooth))
accuracy=sum(abs(HRECG-HR_sp_smooth)<5)/length(HR_sp_smooth)


% close all  %comment this out if you want diagnostic plots
figure
s=surf(t,f*60,p, 'FaceAlpha',0.4);
s.EdgeColor = 'none';
view(0,90)
hold on
plot(t_PPG(I), HR_sp_smooth,t_PPG(I), HRECG,t_PPG(I), HRPPG, t_PPG(I), HR_flat_err)
xlabel('time(s)')
ylabel('BPM')   
ylim([50 200])
legend('PPG Spectrogram', 'HR PPG-sp', 'R-R HR ECG', 'HR PPG-self-consistent', 'HR PPG Time')

%Bland-Altman with ECG and PPG self consistent downsampled to ECG Beats
figure
HRECG_down=interp1(t_PPG(I), HRECG, t_PPG(I));
HRPPG_down=interp1(t_PPG(I), HRPPG, t_PPG(I));
scatter(HRECG_down, HRPPG_down-HRECG_down)

%overlay spectrogram with HR from HR_sp
figure
s=surf(t,f*60,p, 'FaceAlpha',0.4);
s.EdgeColor = 'none';
view(0,90)
hold on
plot(t_PPG(I), HR_sp_smooth)
ylim([0 200])

mean_width=mean((10/1024)*width*60)
std_width=std((10/1024)*width*60)
median_width=median((10/1024)*width*60)
max_width=max((10/1024)*width*60)
