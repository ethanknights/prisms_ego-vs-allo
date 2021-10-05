function plot_diff(d,taskStr,yLimVals,xTickVals)

close all

nSubs = length(d);
%pGColour = {'red','blue'};
cMapCol = lbmap(2,'RedBlue');
%cMapCol = [0 1 0; 0 1 1]; %green L, Blue R


figure('position',[0,0,1000,1000])

for s = 1:nSubs
  
  pG = d(s,3);
  
  plot(d(s,1:2),...
    '-o','Color',cMapCol(pG,:), ...
    'LineWidth',2,'LineStyle','--', ...
    'MarkerSize',18,'MarkerFaceColor',cMapCol(pG,:),'MarkerEdgeColor','black')
  hold on
end


%% other plot formatting
title(sprintf('%s - Accuracy',taskStr),'Interpreter', 'none');
xlabel(['Session']);
xlim([0 3]); set(gca,'XTick',[1:1:3]);
xticklabels(xTickVals);
xtickangle(45)

tmpLim = ylim;
%ylim([tmpLim(1) - 0, tmpLim(2) + 0])
ylim(yLimVals) %[-5,60]
ylabel('Endpoint Error (mm)')

set(gca,'box','off','color','none','TickDir','out','fontsize',18);

%eval(sprintf('export_fig images/%s_matlab.tiff -transparent',taskStr))
fig2svg(sprintf('images/%s_matlab.svg',taskStr))


