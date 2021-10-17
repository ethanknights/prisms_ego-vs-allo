
function plot_task_scatter(fN_PP,fN_AP,yLim,varStr,yLabelStr)

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

[h_PP] = plotCurrTask(tList{1}, nSubs,cMapCol,alphaVal,yLim,'Propointing',varStr,yLabelStr);

[h_AP] = plotCurrTask(tList{2}, nSubs,cMapCol,alphaVal,yLim,'Antipointing',varStr,yLabelStr);

end

%% ========================================================================
function [h] = plotCurrTask(t, nSubs,cMapCol,alphaVal,yLim,titleStr,varStr,yLabelStr)
figure('position',[0,0,1000,1000])

for s = 1:nSubs
  pG = table2array(t(s,2));
  d = table2array(t(s,3:end));
  h = plot(d,...
    '-o','Color',cMapCol(pG,:),...
    'LineWidth',2,'LineStyle','--', ...
    'MarkerSize',15,'MarkerFaceColor',cMapCol(pG,:),'MarkerEdgeColor','black');
  setMarkerColor(h,cMapCol(pG,:),alphaVal);
  pause(0.05)
  hold on
end

%% baseline line
% if doBaseline
%   line([0:23],[zeros(24)],...
%     'col', [0,0,0], 'LineWidth', 2,'LineStyle','--');
% end

%% other plot formatting
title(titleStr,'Interpreter','None');
xlabel('Session'); xlim([0.9 2.1]); set(gca,'XTick',[1:2.1]);
xticklabels({'Pre-Prism','Post-Prism'}); % xtickangle(90);
ylim([yLim(1) - 0, yLim(2) + 0]); ylabel(yLabelStr);
set(gca,'box','off','color','none','TickDir','out','fontsize',18);
ax = gca; ax.XColor = 'black'; ax.YColor = 'black'; ax.LineWidth = 2;

fig2svg(sprintf('images/task-%s_variable-%s_scatter.svg',titleStr,varStr))

eval(...
  sprintf(...
  'export_fig ''images/task-%s_variable-%s_scatter.tiff'' -transparent',...
  titleStr,varStr)...
  )
  
 

end

