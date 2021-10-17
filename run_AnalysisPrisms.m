%% Purpose: Collect Prisms Data & plot
%%
%% Notes:
%% - 'RT' Refers to MT.
%%
%% Ethan Knights
%% ========================================================================

%% Preliminaries:
%% ========================================================================
%% - Ensure preprocessed .xls data directory is present (osf/owncloud). 
%% This dir is set in writeCSv_OL/PP/AP.m

mkdir images
clear
set(0, 'DefaultFigureRenderer', 'painters'); %linux
%set(0, 'DefaultFigureRenderer', 'openGL'); %mac

%% Open Loop
%% ========================================================================
%grabRawData_OL;  %out: rawData_OL.mat
clear; load rawData_OL.mat; 
writeCsv_OL;

%% Plots
%% ------------------------------------------------------------------------
%% directional error
% scatter
plot_OL_scatter('data_openloop_wide_Errorinmm_mean',[-80,80],true);
export_fig 'images/data_openloop_wide_Errorinmm_mean.tiff' -transparent
% errorbar
plot_OL_errorBar('data_openloop_wide_Errorinmm_mean',[-80,80]);
export_fig 'images/data_openloop_wide_Errorinmm_mean_ErrorBar.tiff' -transparent
% line-scatter-errorbar (not using)
plot_OL_scatterANDerrorBar('data_openloop_wide_Errorinmm_mean',[-80,80],true);
export_fig 'images/data_openloop_wide_Errorinmm_mean_scatterANDerrorBar.tiff' -transparent

%% absolute error
% scatter
plot_OL_scatter('data_openloop_wide_Errorinmm_absolute_mean',[-1,80],false);
export_fig 'images/data_openloop_wide_Errorinmm_absolute_mean.tiff' -transparent
% errorbar
plot_OL_errorBar('data_openloop_wide_Errorinmm_absolute_mean',[-1,60]);
export_fig 'images/data_openloop_wide_Errorinmm_absolute_mean_ErrorBar.tiff' -transparent
% line-scatter-errorbar (not using)
plot_OL_scatterANDerrorBar('data_openloop_wide_Errorinmm_absolute_mean',[-1,80],false);
export_fig 'images/data_openloop_wide_Errorinmm_mean_scatterANDerrorBar.tiff' -transparent

%% MT plot
% scatter
plot_OL_scatter('data_openloop_wide_MouseClick1RT_mean',[250,1500],false);
export_fig 'images/data_openloop_wide_MouseClick1RT_mean.tiff' -transparent
% errorbar
plot_OL_errorBar('data_openloop_wide_MouseClick1RT_mean',[400,900]);
export_fig 'images/data_openloop_wide_MouseClick1RT_mean_ErrorBar.tiff' -transparent
% line-scatter-errorbar (not using)
plot_OL_scatterANDerrorBar('data_openloop_wide_MouseClick1RT_mean',[250,1500],false);
export_fig 'images/data_openloop_wide_MouseClick1RT_mean_scatterANDerrorBar.tiff' -transparent


%% Pro-/Anti-Point
%% ========================================================================
%grabRawData_PP_AP;  %out: 'rawData.mat'
clear; load rawData_PP_AP.mat; 
writeCsv_PP;  %out: t_PP + csv/data_propointing.csv
clear; load rawData_PP_AP.mat; 
writeCsv_AP;  %out: t_AP + csv/data_antipointing.csv

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


