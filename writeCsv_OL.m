%% Purpose: Parse matlab raw data files into 
%% Long format data (t_OL)
%% Perform data exclusions
%% Write Long format data (csv/data_openloop_long.csv)
%% convert to wide format and write (csv/data_openloop_wide.csv)

outDir = 'csv'; mkdir(outDir)

%% OL
%% ========================================================================
for s = 1:height(t_wide); ID = t_wide.ID{s}; ID_num = t_wide.ID_num(s);
  
  tmpD = tmpD_OL{s};
  
  tmpH = tmpD(1,:)';
  tmpD = tmpD(2:end,:);
  
  for sess = 1:5
    
    idx_Sess = cell2mat(tmpD(:, strcmp(tmpH,'Session' ))) == sess;
    
    idx_L = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tleft'), ...
      idx_Sess ], 2) );
    idx_C = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tcentre'), ...
      idx_Sess ], 2) );
    idx_R = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tright'), ...
      idx_Sess ], 2) );
    
    %% Put vriables in new tmpT table
    list_vars = {...
      'Error in mm',...
      'MouseClick1X',...
      'MouseClick1Y',...
      'Perfect X',...
      'MouseClick1RT'... %MT actually
      %RT never measured in OpenLoop
      };
    
     list_vars2 = {... %% matlab2019 udpated table name rules
      'Errorinmm',...
      'MouseClick1X',...
      'MouseClick1Y',...
      'PerfectX',...
      'MouseClick1RT'... %MT actually
      %RT never measured in OpenLoop
      };
    
    newRow_L = [];    newRow_C = [];    newRow_R = [];
    for v = 1:length(list_vars); varStr = list_vars{v};
      colIdx = strcmp(tmpH,varStr);
      outCol = v;
      genNewRow_OL %newRow_L, %newRow_R, %newRow_R
    end
  
    tmpT = [newRow_L;newRow_C;newRow_R];
    tmpT = array2table(tmpT);
    tmpT.Properties.VariableNames = list_vars2;
    
    %% condition info (long format)
    tmpT.subNum =         repmat(t_wide.subNum(s),height(tmpT),1);
    tmpT.ID =               repmat(t_wide.ID(s),height(tmpT),1);
    tmpT.ID_num =           repmat(t_wide.ID_num(s),height(tmpT),1);
    tmpT.PrismGroup =       repmat(t_wide.PrismGroup(s),height(tmpT),1);
    tmpT.Session =          repmat(sess,height(tmpT),1);
    tmpT.Target =   [...
      repmat(1,length(idx_L),1);...
      repmat(2,length(idx_C),1);...
      repmat(3,length(idx_R),1);...
      ];
    tmpT.TargetStr =   [...
      repmat('L',length(idx_L),1);...
      repmat('C',length(idx_C),1);...
      repmat('R',length(idx_R),1);...
      ];

    if sess == 1
      tmpT_sess = tmpT;
    else
      tmpT_sess = [tmpT_sess;tmpT];
    end
  
  end
  
  if s == 1
    t_OL = tmpT_sess;
  else
    t_OL = [t_OL;tmpT_sess];
  end

end

%design matrix
im = table2array( t_OL(:,[8:11]))
figure, imagesc(im); colormap('jet') %ID, PrismGroup, Session, Target
im = table2array( t_OL(:,[9:11]))
figure, imagesc(im); colormap('jet') % PrismGroup, Session, Target
close all


%% Absolute Error
%% ------------------------------------------------------------------------
t_OL.AbsErr = abs(t_OL.("Errorinmm"));

%% Data exclusions
%% ------------------------------------------------------------------------
list_subs = sort_nat(unique(t_OL.ID));
nSubs = length(list_subs);

% 1. rm slow/anticipatory (most are non-registered touch-screen response) +/- 3stdev 
[t_OL,uStdev,lStdev] = flag_outliers(t_OL,list_subs,nSubs,'RT'); %new column t.flag_RT
plot_scatter(t_OL,list_subs,nSubs,'RT_beforeDataExclusion',t_OL.MouseClick1RT,60);

t_OL.MouseClick1RT(t_OL.flag_RT) = nan; %drop outliers
t_OL.AbsErr(t_OL.flag_RT) = nan; %drop outliers

plot_descriptives_OL_scatter(t_OL,list_subs,nSubs,'RT',t_OL.MouseClick1RT,60);

%leave errors in for OL (but check for bad subjects..)
[check,uStdev,lStdev]  = flag_outliers(t_OL,list_subs,nSubs,'AbsAcc'); %new column t.flag_accuracy
plot_scatter(t_OL,list_subs,nSubs,'AbsAcc',t_OL.AbsErr,60);
close all

%% Write long format
%% ------------------------------------------------------------------------
writetable(t_OL,fullfile(outDir,'data_openloop_long.csv'))

%% Convert to wide format
%% ------------------------------------------------------------------------
t = readtable(fullfile(outDir,'data_openloop_long.csv'))
%ignore target Side of space + Eccentricity (only for task difficulty)
list_vars = {... %% matlab2019 udpated table name rules
'Errorinmm',...
'MouseClick1X',...
'MouseClick1Y',...
'MouseClick1RT'... %MT actually
};
opStr = 'mean';

statarray = grpstats(t,{'ID_num','Session'},opStr,'DataVars',list_vars);

for v = 1:length(list_vars); varStr = list_vars{v}
  
  t = statarray(:,...
    [1,2,3, find(strcmp(sprintf('%s_%s',opStr,varStr)...
    ,statarray.Properties.VariableNames))]...
    );
  tmpH = t.Properties.VariableNames;
  
  newT = array2table(nan(nSubs,7)); %5 sess + 1 ID + 1 Prism Group
  newT.Properties.VariableNames = {'ID_num', ...
    'PrismGroup',...
    sprintf('Session1_%s',tmpH{end}),...
    sprintf('Session2_%s',tmpH{end}),...
    sprintf('Session3_%s',tmpH{end}),...
    sprintf('Session4_%s',tmpH{end}),...
    sprintf('Session5_%s',tmpH{end}),...
    };
    
  list_ID_num = unique(t.ID_num);
  for s = 1:nSubs; ID_num = list_ID_num(s); idx = find(ID_num == t.ID_num);
    
    newT(s,1) = array2table(ID_num);
    newT(s,2) = array2table(t_wide.PrismGroup(find(ID_num == t_wide.ID_num)));
    for sess = 1:5
      newT(s,2+sess) = t(idx(sess),end); 
    end

  end
    
  writetable(newT,fullfile(outDir,['data_openloop_wide_',varStr,'_',opStr,'.csv']));

end

%% Add AbsErr
t = readtable('csv/data_openloop_wide_Errorinmm_mean.csv');
t.Session1_mean_Errorinmm = abs(t.Session1_mean_Errorinmm);
t.Session2_mean_Errorinmm = abs(t.Session2_mean_Errorinmm);
t.Session3_mean_Errorinmm = abs(t.Session3_mean_Errorinmm);
t.Session4_mean_Errorinmm = abs(t.Session4_mean_Errorinmm);
t.Session5_mean_Errorinmm = abs(t.Session5_mean_Errorinmm);

writetable(t,fullfile(outDir,'data_openloop_wide_Errorinmm_absolute_mean.csv'));

close all