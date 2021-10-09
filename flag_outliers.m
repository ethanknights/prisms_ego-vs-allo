function [t,uStdev,lStdev] = flag_outliers(t,list_subs,nSubs,varStr)

t.flag = repmat(false,height(t),1);

for s = 1:nSubs; ID = list_subs{s}
  idx = find(strcmp(ID,t.ID));
  
  switch varStr
    case 'RT'
        meanVal = mean(t.MouseClick1RT(idx));
        stdevVal = std(t.MouseClick1RT(idx));
    case 'AbsAcc'
      meanVal = mean(t.AbsErr(idx));
      stdevVal = std(t.AbsErr(idx));
  end
  
  uStdev(s) = round(meanVal + (stdevVal * 4)); sprintf('Upper Limit - %g\n',uStdev(s));
  lStdev(s) = round(meanVal - (stdevVal * 4)); sprintf('Upper Limit - %g\n',lStdev(s));
  
  switch varStr
    case 'RT'
      flagIdx = find (  t.MouseClick1RT(idx) > uStdev(s)    | t.MouseClick1RT(idx) < lStdev(s) );
    case 'AbsAcc'
      flagIdx = find (  t.AbsErr(idx) > uStdev(s)  | t.AbsErr(idx) < lStdev(s) );
  end
  t.flag(idx(flagIdx)) = true;
end
sprintf('nFlagged = %d ( %.2f percent)', ...
    length(find(t.flag)),...
    100 / height(t) * length(find(t.flag))...
    )
  
t.Properties.VariableNames(end) = {sprintf('flag_%s',varStr)};

