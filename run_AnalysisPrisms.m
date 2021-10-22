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
%set(0, 'DefaultFigureRenderer', 'painters'); %linux
set(0, 'DefaultFigureRenderer', 'openGL'); %mac

do_rawData_OL = true;
%% Open Loop
%% ========================================================================
if do_rawData_OL
  %grabRawData_OL;                                  %out: rawData_OL.mat
  clear; load rawData_OL.mat; writeCsv_OL;         %out: csv/*openloop*.csv
end

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
do_rawData_PP_AP = true;
if do_rawData_PP_AP
  %grabRawData_PP_AP  %out: 'rawData.mat'
  clear; load rawData_PP_AP.mat; writeCsv_PP;  %out: t_PP + csv/data_propointing.csv
  clear; load rawData_PP_AP.mat; writeCsv_AP;  %out: t_AP + csv/data_antipointing.csv
  
  %% Create new 'data_task_long.csv'
  %concat with 'task' regressor column as a 1/2 for pro/anti
  t1 = readtable('csv/data_propointing_long.csv');
  t1.task = ones(height(t1),1);    t1.taskStr = repmat({'Propointing'},height(t1),1);
  t2 = readtable('csv/data_antipointing_long.csv');
  t2.task = ones(height(t2),1)+1;  t2.taskStr = repmat({'Antipointing'},height(t2),1);
  t = [t1;t2];
  writetable(t,'csv/data_task_long.csv');  % check = readtable('csv/data_task_long.csv')
  
  %% Create new 'data_taskDiff.csv' 
  %create a wide table sub x session1Diff(anti - pro), session2Diff(anti - pro)
  %note - not possible to do this analysis with lmer mixed effect model at 
  %trial level (can't subtract random PP & AP trials!)
  t1 = readtable('csv/data_propointing_wide_Errorinmm_absolute_mean.csv');
  t2 = readtable('csv/data_antipointing_wide_Errorinmm_absolute_mean.csv');
  %init new t
  t = t1;  t(:,end+1) = t2(:,3); t(:,end+1) = t2(:,4);
  t.Properties.VariableNames = {'ID_num','PrismGroup',...
    'PP_session1','PP_session2',...
    'AP_session1','AP_session2'};
  t.Diff_PP = table2array(t1(:,4)) - table2array(t1(:,3));
  t.Diff_AP = table2array(t2(:,4)) - table2array(t2(:,3));
  writetable(t,'csv/data_taskDiff_wide_absErr.csv');
  
  %% extra ttets
  tmpD = [t.Diff_PP,t.Diff_AP];
  [a,b,c,d] = ttest(tmpD)
  clf; for s=1:length(tmpD); plot(tmpD(s,:)); hold on; end
  mean(tmpD)
  
  %% Plots
  %% ------------------------------------------------------------------------
  clear
  
  %% absolute error
  % scatter
  plot_task_scatter(...
    'data_propointing_wide_Errorinmm_absolute_mean',...
    'data_antipointing_wide_Errorinmm_absolute_mean',...
    [-1,80],...
    'AbsErr',...
    'Absolute Error (mm)');
  %errorbar
  plot_task_errorBar(...
    'data_propointing_wide_Errorinmm_absolute_mean',...
    'data_antipointing_wide_Errorinmm_absolute_mean',...
    [0,50],...
    'AbsErr',...
    'Absolute Error (mm)');
end

% t_PP = readtable('csv/data_propointing.csv');
% t_AP = readtable('csv/data_antipointing.csv');
% 
% 
% [d_PP] = plot_task(t_PP,'Pro-Pointing');
% [d_AP] = plot_task(t_AP,'Anti-Pointing');
% close all
% 
% %% plot Task Difference
% d = d_AP - d_PP;
% d(:,3) = d_PP(:,3); %fix prism group (PP,AP same!)
% plot_diff(abs(d),'TaskDifference_AP-PP_absolute',[-5,60],{'Pre-Prism','Post-Prism'});
% plot_diff(d,'TaskDifference_AP-PP_directional',[-80,80], {'Pre-Prism','Post-Prism'});
% 
% %% plot Session Difference
% d(:,1) = d_PP(:,2) - d_PP(:,1);
% d(:,2) = d_AP(:,2) - d_AP(:,1);
% d(:,3) = d_PP(:,3); %fix prism group (PP,AP same!)
% plot_diff(abs(d),'SessionDifference_Post-Pre_absolute',[-5,60],{'Pro-point','Anti-point'});
% plot_diff(d,'SessionDifference_Post-Pre_directional',[-80,80], {'Pro-point','Anti-point'});
% 
% 
