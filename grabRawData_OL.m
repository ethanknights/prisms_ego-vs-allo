%% OPEN LOOP
%% ====================
%% Note - currently dropping subj with missing tp2 OL (for simplicity)
%% Strong prism effect across cohorts anyway even with N-1
% see   %'L_11_missOL';
%% ========================================================================
clear

rawDir = '/Users/ethanknights/ownCloud/projects/prisms/Processed_data/';

%% Gather info (once)
%% loop for Left and Right prism groups
% list_groupStr = {'L','R'};
%% jsut get info..
% for currGroup = 1:2;  groupStr = list_groupStr{currGroup};
%   dirCont = dir(fullfile(rawDir,[groupStr,'_*']));
% end
% {dirCont.name}
% natsort( {'L_10','L_11_missOL','L_12','L_13','L_14','L_15','L_16','L_2','L_6','L_7','L_8','L_9'} )'
% natsort( {'R_17','R_18','R_19','R_20','R_21','R_22','R_23','R_24','R_25','R_26','R_4','R_5'} )'

fN_L = {'L_2';
  'L_6';
  'L_7';
  'L_8';
  'L_9';
  'L_10';
  %'L_11'; %missing 1 OL
  'L_12';
  'L_13';
  'L_14';
  'L_15';
  'L_16'};

fN_R = {'R_4';
  'R_5';
  'R_17';
  'R_18';
  'R_19';
  'R_20';
  'R_21';
  'R_22';
  'R_23';
  'R_24';
  'R_25';
  'R_26'};

t_wide = table( [fN_L;fN_R],[ones(length(fN_L),1)*1;ones(length(fN_R),1)*2] );

%% trim strings for sub number only
for s = 1:length(t_wide.Var1); ID = t_wide.Var1{s};
  if length(ID) == 3
    out(s) = str2num ( ID(3) );
  else 
    out(s) = str2num( ID(3:4) );
  end
end
t_wide = table( [1:s]',...
  [fN_L;fN_R],...
  out',...
  [ones(length(fN_L),1)*1;ones(length(fN_R),1)*2]...
  );
t_wide.Properties.VariableNames = {'subNum','ID','ID_num','PrismGroup'};
%% Prism Group 1 = left, 2 = right (from old excel)



%collect subID, age & gender from complete_database.xls (one day..)
%age = ;
% mean(age(2:end))
% std(age(2:end))
% min(age(2:end))
% max(age(2:end))
% [h,p,ci,stats] = ttest(age(2:end),age(1))


%% Read 2014 .xlsx files 
%% (.txt file format changes too much, to re-extract without eprime access)
prestoredfN = 'rawData_OL.mat';

if ~exist(prestoredfN) %if first time
  for s = 1:height(t_wide); ID = t_wide.ID{s}; ID_num = t_wide.ID_num(s);
    
    %% OL
    fN = fullfile(rawDir,ID,sprintf('Openloop-%d-1+2+3+4+5.xlsx',ID_num));
    [~,~,tmpD_OL{s}] = xlsread(fN,sprintf('Openloop-%d-1',ID_num));
    %% PP
    %fN = fullfile(rawDir,ID,sprintf('Pro-Pointing-%d-1+2.xlsx',ID_num));
    %[~,~,tmpD_PP{s}] = xlsread(fN,sprintf('Pro-Pointing-%d-1',ID_num));
    %% AP
    %fN = fullfile(rawDir,ID,sprintf('Anti-Pointing-%d-1+2.xlsx',ID_num));
    %[~,~,tmpD_AP{s}] = xlsread(fN,sprintf('Anti-Pointing-%d-1',ID_num));
    
  end
  save(prestoredfN,'tmpD_OL','t_wide'); else
  load(prestoredfN,'tmpD_OL','t_wide'); end
  %save(prestoredfN,'tmpD_OL','tmpD_PP','tmpD_AP','t_wide'); else
  %load(prestoredfN,'tmpD_OL','tmpD_PP','tmpD_AP','t_wide'); end
  