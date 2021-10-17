
function plot_task_errorBar(fN_PP,fN_AP,yLim,varStr,yLabelStr)

t_PP = readtable(sprintf('csv/%s.csv',fN_PP));
t_AP = readtable(sprintf('csv/%s.csv',fN_AP));
subs = unique(t_PP.ID_num);
nSubs = length(subs);

tList = {t_PP,t_AP};

close all


%pGColour = {'red','blue'};
%cMapCol = lbmap(2,'BrownBlue'); %red left, blue Right
%cMapCol = [0 1 0; 0 1 1]; %green L, Blue R
cMapCol = ... %better grayscale visibility
  [0.4940 0.1840 0.5560; 0.3010 0.7450 0.9330]; %purple left, blue right
alphaVal = 0.8;


% for currT = 1:2
%   eval(sprintf('t = tList{%d}',currT))

plotCurrTask(tList{1}, nSubs,cMapCol,alphaVal,yLim,'Propointing',varStr,yLabelStr);

plotCurrTask(tList{2}, nSubs,cMapCol,alphaVal,yLim,'Antipointing',varStr,yLabelStr);

end

%% ========================================================================
function plotCurrTask(t, nSubs,cMapCol,alphaVal,yLim,titleStr,varStr,yLabelStr)

tmpD = table2array(t(:,3:end));
nSess = size(tmpD,2);
nSEMs = 2;

figure('position',[0,0,1000,1000])
%% Left prism group
pG = 1; doErrorBars(t,pG,cMapCol,nSEMs,nSess,tmpD);
%% Right prism group
pG = 2; doErrorBars(t,pG,cMapCol,nSEMs,nSess,tmpD);

%% other plot formatting
title(titleStr,'Interpreter','None');
xlabel('Session'); xlim([0.9 2.1]); set(gca,'XTick',[1:2.1]);
xticklabels({'Pre-Prism','Post-Prism'}); % xtickangle(90);
ylim([yLim(1) - 0, yLim(2) + 0]); ylabel(yLabelStr);
set(gca,'box','off','color','none','TickDir','out','fontsize',18);
ax = gca; ax.XColor = 'black'; ax.YColor = 'black'; ax.LineWidth = 2;

fig2svg(sprintf('images/task-%s_variable-%s_errorBar.svg',titleStr,varStr))

eval(...
  sprintf(...
  'export_fig ''images/task-%s_variable-%s_errorBar.tiff'' -transparent',...
  titleStr,varStr)...
  )
end

function doErrorBars(t,pG,cMapCol,nSEMs,nSess,tmpD)

for i = 1:nSess
  
  prismIdx = find(t.PrismGroup == pG);
  
  means(i) = mean(tmpD(prismIdx,i));
  SEM(i) = nSEMs * std(tmpD(prismIdx,i)) / sqrt(length(prismIdx));
  %       err(i,1) = means(i) + nSEMs * ...
  %         std(tmpD(prismIdx,i)) / sqrt(length(prismIdx));
  %       err(i,2) = means(i) - nSEMs * ...
  %         std(tmpD(prismIdx,i)) / sqrt(length(prismIdx));
end

h = errorbar(means,SEM ,...
  'Color',cMapCol(pG,:),'LineWidth',2,'LineStyle','-','Capsize',40,...
  'marker','o','markersize',10,'markerfacecolor','black');
hold on
%     h = errorbar([1:2], means, err(:,1),err(:,2),...
%       'Color',cMapCol(pG,:),'LineWidth',2,'LineStyle','-','Capsize',40,...
%       'marker','o','markersize',10,'markerfacecolor','black');
%
%     h.Bar.LineStyle = 'solid'; %'solid'|'dashed' |'dotted'|'dashdot'|'none'
%     hold on
end

