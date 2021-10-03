%% Purpose: Collect Prisms Data
%% ?Put in long format for R ANVOA?

%%Preliminaries:
% - Have Preprocessed Data directory. 
%% ========================================================================
clear

%% Parameters
%% ========================================================================


%% Grab raw Data
%% ========================================================================
done_rawData = true;
if ~done_rawData   
  grabRawData;  %out: 'rawData.mat'
  dataToLong;   %out: 'longD_OL.csv','longD_PP.csv','longD_AP.csv'
end

plot_OL


% thisVarStr = 'ANGerr';
% data = getData(thisVarStr,rawData,sNames);
% 
% %% Now check trialDistributions:
% checkTrials
 
% conditionNames = {'RHFREE','RHPER','LHFREE','LHPER'};
% sNames = {
%   'DA',
%   'NH06',
%   'CT07',
%   'EH09',
%   'AW07',
%   'UB03',
%   'BT07',
%   'VH11',
%   'RN07',
%   'RS24',
%   'SMS05'}; %without AL10!!
% age = [67,
%   62,
%   64,
%   69,
%   63,
%   66,
%   71,
%   64,
%   66,
%   59,
%   75]; %without AL10!!
% mean(age(2:end))
% std(age(2:end))
% min(age(2:end))
% max(age(2:end))
% [h,p,ci,stats] = ttest(age(2:end),age(1)) %p reported in the paper reflects 
% %the full control group age comparison earlier (p still >.05; p = 0.476).
% 
% %% Read data
% rawData = [];
% fN = fullfile('data','data.mat');
% rfN = fullfile('data','FREEPER_Database.xlsx');
% if ~exist(fN) %if first time
%   for s = 1:size(sNames)
%     for condition = 1:4
%       tmpName = sprintf('%s_%s',sNames{s},conditionNames{condition});
%       [~,~,rawData{s,condition}] = xlsread(rfN,tmpName);
%     end
%   end
%   save(fN,'rawData');
% else
%   load(fN); %else load data
% end
% disp('done writing rawData to data.mat')
% 
% 
% %% ==== ANALYSIS ==== %%
% 
% listVarStrs = { 'ANGerr', ...
%                 'XError', ... %delete spaces later, so not 'X Error ' etc
%                 'YError', ...
%                 'reactiontime', ...
%                 'movementtime'}; 
% listAxisVal_allTargets_y_ttest = {  [-8 8], ...
%                                     [-35 35], ...
%                                     [-50 50], ...
%                                     [0 1500], ...
%                                     [0 1800]};
% listAxisVal_sideOfSpace_y_ttest = { [-4 4], ...
%                                     [-20 20], ...
%                                     [-35 35], ...
%                                     [0 1500], ...
%                                     [0 1800]};
% listAxisVal_allTargets_y_BDST = {   [-8 8], ...
%                                     [-35 35], ...
%                                     [-50 50], ...
%                                     [-800 1500], ...
%                                     [-1800 1800]};
% listAxisVal_sideOfSpace_y_BDST = {  [-4 4], ...
%                                     [-20 20], ...
%                                     [-35 35], ...
%                                     [-800 1500], ...
%                                     [-1800 1800]};
% for v = 1:length(listVarStrs)
%   
%   thisVarStr = listVarStrs{v};
%   axisVal_allTargets_y_ttest = listAxisVal_allTargets_y_ttest{v};
%   axisVal_sideOfSpace_y_ttest = listAxisVal_sideOfSpace_y_ttest{v};
%   
%   axisVal_allTargets_y_BDST = listAxisVal_allTargets_y_BDST{v};
%   axisVal_sideOfSpace_y_BDST = listAxisVal_sideOfSpace_y_BDST{v};
%   
%   
%   [data,tmpH] = getData(thisVarStr,rawData,sNames);
%   
%   
%   outDir = fullfile('results',thisVarStr); 
%   try
%     rmdir(outDir,'s');
%   catch
%     %NOOP
%   end
%   mkdir(outDir)
%   
%   
%   diary(fullfile(outDir,[thisVarStr,'_inputForCrawford-SingleBayes_ES.txt']));
%   stats = doCrawfordTtest_allTargets(thisVarStr,data,conditionNames,outDir,axisVal_allTargets_y_ttest);
%   stats = doCrawfordTtest_sideOfSpace(thisVarStr,data,conditionNames,outDir,axisVal_sideOfSpace_y_ttest);
%   diary OFF
% 
%   diary(fullfile(outDir,[thisVarStr,'_inputForCrawford-DissocsBayes_ES.txt']));
%   plotBDST_allTargets(thisVarStr,data,conditionNames,outDir,axisVal_allTargets_y_BDST);
%   plotBDST_sideOfSpace(thisVarStr,data,conditionNames,outDir,axisVal_sideOfSpace_y_BDST);
%   diary OFF
% end
% 
% %% repeat ANALYSIS with absolute error measures
% repeatWithAbsolute %ANGERR_ABSOLUTE etc. %a branch would have been smarter!!
% 
% 
% %% plot raw pointing coordinates
% plotRawPointingCoordinates
% 
