function plot_descriptives_scatter(t,list_subs,nSubs,titleStr,variable,nTrials,taskStr)
%nSubs = 3


yLim = [min(variable),max(variable)];
xLim = [0,(nTrials+1)];

if logical(contain('AbsAcc',{titleStr}))
  yLim = [min(variable),max(variable)+10];
elseif logical(contain('RT',{titleStr}))
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
%fig2svg(sprintf('images/%s_subplotScatter_%s.svg',taskStr,titleStr)) %subplot breaks
saveas(gca,sprintf('images/%s_subplotScatter_%s.png',taskStr,titleStr))

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
fig2svg(sprintf('images/%s_groupScatter_%s.svg',taskStr,titleStr))

% 
% pd = fitdist(variable,'Normal');
% x_values = min(variable):100:max(variable);%not sure what step to use
% y = pdf(pd,x_values);
% figure,plot(x_values,y,'LineWidth',2);
% hold on;
% histogram(variable,30);
