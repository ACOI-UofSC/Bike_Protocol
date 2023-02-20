% HR_spect_smooth;

%%%Plot polar data
%import polar
filename_polar='6_3_Polar.xlsx';

POLAR = importdata(filename_polar,'',1);
t_polar=POLAR.data(10+trial_start:10+trial_length,1)';
t_polar=t_polar-t_polar(1)-2;%set timer to zero
HR_polar=POLAR.data(10+trial_start:10+trial_length,2)';


close all

s=surf(t,f*60,p, 'FaceAlpha',0.4);
s.EdgeColor = 'none';
view(0,90)
hold on
plot(t_PPG(I), HR_sp_smooth)
ylim([0 200])

%resample HR_polar to PPG data
HR_polar_interp=interp1(t_polar, HR_polar, t_PPG(I));  %HR_sp_smooth upsample to t_PPG x-axis

plot(t_PPG(I), HR_polar_interp)
legend('PPG Spectrogram', 'HR PPG-sp', 'HR Polar')
%Bland Atlman
figure
scatter(HR_polar_interp, (HR_sp_smooth-HR_polar_interp))

rmserror=nanstd((HR_sp_smooth-HR_polar_interp)./HR_polar_interp)
rmsbias=nanstd((HR_sp_smooth-HR_polar_interp))
mean_abs_bias=nanmean(abs(HR_sp_smooth-HR_polar_interp))
self_consistency=sum(abs(HR_polar_interp-HR_sp_smooth)<10)/length(HR_sp_smooth)
accuracy=sum(abs(HR_polar_interp-HR_sp_smooth)<5)/length(HR_sp_smooth)

