

outDir = 'csv'; mkdir(outDir)

%% Pro-Pointing
%% ========================================================================
for s = 1:height(t_wide); ID = t_wide.ID{s}; ID_num = t_wide.ID_num(s);
  
  tmpD = tmpD_PP{s};
  
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
    tmpT.Properties.VariableNames = list_vars;
    
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
    t_PP = tmpT_sess;
  else
    t_PP = [t_PP;tmpT_sess];
  end

end

%design matrix
im = table2array( t_PP(:,[8:11]))
figure, imagesc(im); colormap('jet') %ID, PrismGroup, Session, Target
im = table2array( t_PP(:,[9:11]))
figure, imagesc(im); colormap('jet') % PrismGroup, Session, Target

writetable(t_PP,fullfile(outDir,'data_propointing.csv'))

 