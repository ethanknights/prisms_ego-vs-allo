function [data,tmpH] = getData(thisVarStr,rawData,sNames)

%% Get data for seven targets per condition
targetStack = [];
targetMean = [];
targetStd = [];
nTrials = [];
for s = 1:length(sNames)
  for condition = 1:4
    
    tmpD = rawData{s,condition};
    
    %grab headers for the standard columns (32+ might differ)
    tmpH = strrep(tmpD(1,1:31), ' ' ,'')'; %dont deblnk, just delete space for paths
    
    idx = find(cell2mat(cellfun(@(x) strcmp(thisVarStr,x),tmpH,'UniformOutput',false)));
    assert(length(idx) == 1,sprintf('thisVarStr %s not found for sub-%d condition-%d',thisVarStr,s,condition));
    
    for target = 1:7
      [targetStack{s,target,condition},targetMean(s,target,condition),targetStd(s,target,condition)] = getTargetMean_AbsoluteVersion(tmpD,target,idx);
      nTrials(s,target,condition) = length(targetStack{s,target,condition});
    end
  end
end
%Store data in structure
data.targetStack = targetStack;
data.targetMean = targetMean;
data.targetStd = targetStd;
data.nTrials = nTrials; %%Check nTrials stats once for methods: nTrialsStats.m
%could check for age covariate, but silly with N=10 and a signed error: checkAgeCorrelation.m

