function plot_descriptives_OL_scatter(t,list_subs,nSubs,titleStr,variable,nTrials)
%nSubs = 3


yLim = [min(variable),max(variable)];
xLim = [0,(nTrials+1)];

if strcmp(titleStr,'AbsAcc')
  yLim = [min(variable),max(variable)+10];
elseif contains(titleStr,'RT')
  yLim = [min(variable)-250,max(variable)+250];
end

%subplot - subject scatters
figure('position',[0,0,1000,1000])
for s = 1:nSubs; ID = list_subs{s}; idx = find(strcmp(ID,t.ID));
  subplot(6,4,s)
  scatter([find(idx)],variable(idx))
  title(unique(t.ID(idx)),'Interpreter','none')
  xlabel('trialNumber')
  ylabel(titleStr)
  ylim(yLim); xlim(xLim);
end
sgtitle(titleStr)
%fig2svg(sprintf('images/OL_subplotScatter_%s_matlab.svg',titleStr))
saveas(gca,sprintf('images/OL_subplotScatter_%s_matlab.svg',titleStr))

%group scatter
figure('position',[0,0,1000,1000])
cMapCol = lbmap(nSubs,'RedBlue');
for s = 1:nSubs; ID = list_subs{s}; idx = find(strcmp(ID,t.ID));
  
  plot([find(idx)],variable(idx),...
    'o','Color',cMapCol(s,:), ...
    'MarkerSize',12,'MarkerFaceColor',cMapCol(s,:),'MarkerEdgeColor','black')
  hold on
end
xlabel('trialNumber');
ylabel(titleStr);
ylim(yLim); xlim(xLim);
title(titleStr)
fig2svg(sprintf('images/OL_groupScatter_%s_matlab.svg',titleStr))

