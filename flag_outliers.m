function [t,uStdev] = flag_outliers(t,list_subs,nSubs,varStr)

t.flag = repmat(false,height(t),1);

for s = 1:nSubs; ID = list_subs{s};
  idx = find(strcmp(ID,t.ID));
  
  switch varStr
    case 'RT'
        meanVal = nanmean(t.MouseClick1RT(idx));
        stdevVal = nanstd(t.MouseClick1RT(idx));
    case 'AbsAcc'
      meanVal = nanmean(t.AbsErr(idx));
      stdevVal = nanstd(t.AbsErr(idx));
  end
  
  uStdev(s) = round(meanVal + (stdevVal * 2)); sprintf('%s Upper Limit - %g\n',varStr, uStdev(s));
  lStdev(s) = round(meanVal - (stdevVal * 2)); sprintf('%s Lower Limit - %g\n',varStr, lStdev(s));
 
  switch varStr
    case 'RT'
      flagIdx = find ( t.MouseClick1RT(idx) > uStdev(s)  | t.MouseClick1RT(idx) < lStdev(s) );
    case 'AbsAcc'
      flagIdx = find ( t.AbsErr(idx) > uStdev(s)         | t.AbsErr(idx) < lStdev(s) );
  end
  t.flag(idx(flagIdx)) = true;
end
sprintf('%s nFlagged = %d ( %.2f percent)', ...
    varStr,...
    length(find(t.flag)),...
    100 / height(t) * length(find(t.flag))...
    )
  
t.Properties.VariableNames(end) = {sprintf('flag_%s',varStr)};

