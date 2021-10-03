%% nTrials for methods (same regardless of measure; so only do this once:)
tmpD = data.nTrials;

%% NTRIALS ANALYSED
nTrial_means = [];

%% some descriptives: DA
sum(sum(tmpD(1,:,:))) %total trials

for c = 1:4
  tmp = tmpD(1,:,c); %1 is DA
  
  fprintf('DA %s mean =%s\n',  conditionNames{c}, num2str( mean(tmp) ))
  nTrial_means(1,c) = mean(tmp);
  fprintf('DA %s  std =%s\n',  conditionNames{c}, num2str( std(tmp) ))
  fprintf('DA %s  min =%s\n',  conditionNames{c}, num2str( min(tmp) ))
  fprintf('DA %s  max =%s\n',  conditionNames{c}, num2str( max(tmp) ))
  
end

%% Some descriptives: controls
for s = 2:length(sNames)
  for c = 1:4
    tmp = tmpD(s,:,c); %1 is DA
    
    nTrial_means(s,c) = mean(tmp);
    
  end
end
for c = 1:4
  fprintf('CONTROL %s mean =%s\n',  conditionNames{c}, num2str( mean(nTrial_means(2:11,c)) ))
  fprintf('CONTROL %s  std =%s\n',  conditionNames{c}, num2str( std(nTrial_means(2:11,c)) ))
  fprintf('CONTROL %s  min =%s\n',  conditionNames{c}, num2str( min(nTrial_means(2:11,c)) ))
  fprintf('CONTROL %s  max =%s\n',  conditionNames{c}, num2str( max(nTrial_means(2:11,c)) ))
end
%write for R singcar
writematrix(nTrial_means,fullfile('data','trialDistributions','forCrawfordTest_ntrials.csv'))








return

