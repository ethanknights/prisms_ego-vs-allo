%% Purpose: Collect Prisms Data
%% ?Put in long format for R ANVOA?

%% Preliminaries:
% - Have Preprocessed Data directory. 
%% ========================================================================
mkdir images
clear
set(0, 'DefaultFigureRenderer', 'painters'); %linux
%set(0, 'DefaultFigureRenderer', 'openGL'); %mac

%% OPEN LOOP
%% ========================================================================
%grabRawData_OL;  %out: rawData_OL.mat
clear; load rawData_OL.mat; 
writeCsv_OL;

plot_OL('data_openloop_wide_Errorinmm_mean',[-80,80]);
export_fig 'images/data_openloop_wide_Errorinmm_mean.tiff' -transparent

plot_OL('data_openloop_wide_Errorinmm_absolute_mean',[-1,80]);
export_fig 'images/data_openloop_wide_Errorinmm_absolute_mean.tiff' -transparent

plot_OL('data_openloop_wide_MouseClick1RT_mean',[0,1500]);
export_fig 'images/data_openloop_wide_MouseClick1RT_mean.tiff' -transparent


%% Pro-/Anti-Point
%% ========================================================================
%grabRawData_PP_AP;  %out: 'rawData.mat'
clear; load rawData_PP_AP.mat; 
dataToLong_PP;  %out: t_PP + csv/data_propointing.csv
dataToLong_AP;  %out: t_AP + csv/data_antipointing.csv

clear
t_PP = readtable('csv/data_propointing.csv');
t_AP = readtable('csv/data_antipointing.csv');

[d_PP] = plot_task(t_PP,'Pro-Pointing');
[d_AP] = plot_task(t_AP,'Anti-Pointing');
close all

%% plot Task Difference
d = d_AP - d_PP;
d(:,3) = d_PP(:,3); %fix prism group (PP,AP same!)
plot_diff(abs(d),'TaskDifference_AP-PP_absolute',[-5,60],{'Pre-Prism','Post-Prism'});
plot_diff(d,'TaskDifference_AP-PP_directional',[-80,80], {'Pre-Prism','Post-Prism'});

%% plot Session Difference
d(:,1) = d_PP(:,2) - d_PP(:,1);
d(:,2) = d_AP(:,2) - d_AP(:,1);
d(:,3) = d_PP(:,3); %fix prism group (PP,AP same!)
plot_diff(abs(d),'SessionDifference_Post-Pre_absolute',[-5,60],{'Pro-point','Anti-point'});
plot_diff(d,'SessionDifference_Post-Pre_directional',[-80,80], {'Pro-point','Anti-point'});


