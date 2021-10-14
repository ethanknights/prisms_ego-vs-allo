

outDir = 'csv'; mkdir(outDir)

%% Pro-Pointing
%% ========================================================================
for s = 1:height(t_wide); ID = t_wide.ID{s}; ID_num = t_wide.ID_num(s);
  
  tmpD = tmpD_AP{s};
  
  tmpH = tmpD(1,:)'; %15+ are old xls summaries
  tmpD = tmpD(2:end,:);
  
  for sess = 1:2
    
    idx_Sess = cell2mat(tmpD(:, strcmp(tmpH,'Session' ))) == sess;
    
    idx_L15 = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tleft15'), ...
      idx_Sess ], 2) );
    idx_L19 = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tleft19'), ...
      idx_Sess ], 2) );
    idx_L23 = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tleft23'), ...
      idx_Sess ], 2) );
    idx_R15 = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tright15'), ...
      idx_Sess ], 2) );
    idx_R19 = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tright19'), ...
      idx_Sess ], 2) );
    idx_R23 = find( all( [ strcmp( tmpD(:, strcmp(tmpH,'Target' )), 'Tright23'), ...
      idx_Sess ], 2) );

    
    %% Put vriables in new tmpT table
    list_vars = {...
      'Error in mm',...
      'MouseClick1X',...
      'MouseClick1Y',...
      'Perfect X',...
      'MouseClick1RT'... %MT actually
      %RT not properly measured
      };
    
    list_vars2 = {... %% matlab2019 udpated table name rules
      'Errorinmm',...
      'MouseClick1X',...
      'MouseClick1Y',...
      'PerfectX',...
      'MouseClick1RT'... %MT actually
      %RT never measured in OpenLoop
      };
    
    newRow_L15 = [];    newRow_L19 = [];    newRow_L23 = [];
    newRow_R15 = [];    newRow_R19 = [];    newRow_R23 = [];
    for v = 1:length(list_vars); varStr = list_vars{v};
      colIdx = strcmp(tmpH,varStr);
      outCol = v;
      genNewRow_PP_AP %newRow_L, %newRow_R, %newRow_R
    end
  
    tmpT = [newRow_L15;newRow_L19;newRow_L23;...
            newRow_R15;newRow_R19;newRow_R23];
    tmpT = array2table(tmpT);
    tmpT.Properties.VariableNames = list_vars2;
    
    %% condition info (long format)
    tmpT.subNum =         repmat(t_wide.subNum(s),height(tmpT),1);
    tmpT.ID =               repmat(t_wide.ID(s),height(tmpT),1);
    tmpT.ID_num =           repmat(t_wide.ID_num(s),height(tmpT),1);
    tmpT.PrismGroup =       repmat(t_wide.PrismGroup(s),height(tmpT),1);
    tmpT.Session =          repmat(sess,height(tmpT),1);
    tmpT.Target =   [...
      repmat(1,length(idx_L15),1);...
      repmat(2,length(idx_L19),1);...
      repmat(3,length(idx_L23),1);...
      repmat(4,length(idx_R15),1);...
      repmat(5,length(idx_R19),1);...
      repmat(6,length(idx_R23),1);...
      ];
    tmpT.TargetStr =   [...
      repmat('L15',length(idx_L15),1);...
      repmat('L19',length(idx_L19),1);...
      repmat('L23',length(idx_L23),1);...
      repmat('R15',length(idx_R15),1);...
      repmat('R19',length(idx_R19),1);...
      repmat('R23',length(idx_R23),1);...
      ];

    if sess == 1
      tmpT_sess = tmpT;
    else
      tmpT_sess = [tmpT_sess;tmpT];
    end
  
  end
  
  if s == 1
    t_AP = tmpT_sess;
  else
    t_AP = [t_AP;tmpT_sess];
  end

end

%design matrix
im = table2array( t_AP(:,[8:11]));
figure, imagesc(im); colormap('jet') %ID, PrismGroup, Session, Target
im = table2array( t_AP(:,[9:11]));
figure, imagesc(im); colormap('jet') % PrismGroup, Session, Target
close all

%% Absolute Error
%% ------------------------------------------------------------------------
t_AP.AbsErr = abs(t_AP.("Errorinmm"));

%% Data exclusions
%% ------------------------------------------------------------------------
t = t_AP;
list_subs = sort_nat(unique(t.ID));
nSubs = length(list_subs);

% 1. rm slow/anticipatory (most are non-registered touch-screen response) +/- 4stdev
close all
%identify outliers
[t,uStdev,lStdev] = flag_outliers(t,list_subs,nSubs,'RT'); %new column t.flag_RT
%plot with outliers
plot_descriptives_scatter(t,list_subs,nSubs,...
  'RT_beforeDataExclusion',t.MouseClick1RT,60,'task-PP');
%drop outliers
t.MouseClick1RT(t.flag_RT) = nan;
t.AbsErr(t.flag_RT) = nan;
%plot without outliers
plot_descriptives_scatter(t,list_subs,nSubs,...
  'RT',t.MouseClick1RT,60,'task-PP'); %R_4 really slow

%2. leave errors in for error stdev (but check for bad subjects..)
close all
%plot with outliers
plot_descriptives_scatter(t,list_subs,nSubs,...
  'AbsErr',t.AbsErr,60,'task-PP'); %R_4 really weird behaviour slow considerr emoving
%identify outliers
[check,uStdev,lStdev] = flag_outliers(t,list_subs,nSubs,'AbsAcc'); %new column t.flag_accuracy

%3. drop responses to wrong side of space
close all
%identify outliers
[t] = flag_outliers_sideofspace(t,list_subs,nSubs,'AbsAcc'); %new column t.flag_accuracy_sideofspace
%plot with outliers
plot_descriptives_scatter(t,list_subs,nSubs,...
  'AbsErr_beforeDataExclusion',t.AbsErr,60,'task-PP');
%drop outliers
t.MouseClick1RT(t.flag_AbsAcc_sideofspace) = nan;
t.AbsErr(t.flag_AbsAcc_sideofspace) = nan;
%plot without outliers
plot_descriptives_scatter(t,list_subs,nSubs,...
  'AbsErr',t.AbsErr,60,'task-PP');


%% Write long format
%% ------------------------------------------------------------------------
close all
writetable(t,fullfile(outDir,'data_propointing_long.csv'));

%% Convert to wide format
%% ------------------------------------------------------------------------
t = readtable(fullfile(outDir,'data_propointing_long.csv'));
%ignore target Side of space + Eccentricity (only for task difficulty)
list_vars = {... %% matlab2019 udpated table name rules
'Errorinmm',...
'MouseClick1X',...
'MouseClick1Y',...
'MouseClick1RT'... %MT actually
};
opStr = 'mean';

statarray = grpstats(t,{'ID_num','Session'},opStr,'DataVars',list_vars);

for v = 1:length(list_vars); varStr = list_vars{v};
  
  t = statarray(:,...
    [1,2,3, find(strcmp(sprintf('%s_%s',opStr,varStr)...
    ,statarray.Properties.VariableNames))]...
    );
  tmpH = t.Properties.VariableNames;
  
  newT = array2table(nan(nSubs,4)); %2 sess + 1 ID + 1 Prism Group
  newT.Properties.VariableNames = {'ID_num', ...
    'PrismGroup',...
    sprintf('Session1_%s',tmpH{end}),...
    sprintf('Session2_%s',tmpH{end}),...
    };
    
  list_ID_num = unique(t.ID_num);
  for s = 1:nSubs; ID_num = list_ID_num(s); idx = find(ID_num == t.ID_num);
    
    newT(s,1) = array2table(ID_num);
    newT(s,2) = array2table(t_wide.PrismGroup(find(ID_num == t_wide.ID_num)));
    for sess = 1:2
      newT(s,2+sess) = t(idx(sess),end); 
    end

  end
    
  writetable(newT,fullfile(outDir,['data_openloop_wide_',varStr,'_',opStr,'.csv']));

end

%% Add AbsErr
t = readtable('csv/data_propointing_wide_Errorinmm_mean.csv');
t.Session1_mean_Errorinmm = abs(t.Session1_mean_Errorinmm);
t.Session2_mean_Errorinmm = abs(t.Session2_mean_Errorinmm);
t.Session3_mean_Errorinmm = abs(t.Session3_mean_Errorinmm);
t.Session4_mean_Errorinmm = abs(t.Session4_mean_Errorinmm);
t.Session5_mean_Errorinmm = abs(t.Session5_mean_Errorinmm);

writetable(t,fullfile(outDir,'data_propointing_wide_Errorinmm_absolute_mean.csv'));

close all

 