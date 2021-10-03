%conditionNames = {'OL','RHPER','LHFREE','LHPER'};

outDir = 'csv'; mkdir(outDir)

%% OL
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
    newRow_L = [];    newRow_C = [];    newRow_R = [];
    for v = 1:length(list_vars); varStr = list_vars{v};
      colIdx = strcmp(tmpH,varStr);
      outCol = v;
      genNewRow %newRow_L, %newRow_R, %newRow_R
    end
  
    tmpT = [newRow_L;newRow_C;newRow_R];
    tmpT = array2table(tmpT);
    tmpT.Properties.VariableNames = list_vars;
    
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

writetable(t_OL,fullfile(outDir,'data_openloop.csv'))

 