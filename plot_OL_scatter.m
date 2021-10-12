
function plot_OL_scatter(fN,yLim,doBaseline)

t = readtable(sprintf('csv/%s.csv',fN));

close all
subs = unique(t.ID_num);
nSubs = length(subs);

%pGColour = {'red','blue'};
%cMapCol = lbmap(2,'BrownBlue'); %red left, blue Right
%cMapCol = [0 1 0; 0 1 1]; %green L, Blue R
cMapCol = ... %better grayscale visibility
  [0.4940 0.1840 0.5560; 0.3010 0.7450 0.9330]; %purple left, blue right
alphaVal = 0.8;

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

%% other plot formatting
title('Open Loop Pointing');
xlabel('Session'); xlim([0.75 5.25]); set(gca,'XTick',[1:1:5]);
xticklabels({'Pre-Sham','Post-Sham','Pre-Prism','Post-Prism','Late-Prism'}); 
xtickangle(90);
ylim([yLim(1) - 0, yLim(2) + 0]); ylabel('Endpoint Error (mm)');
set(gca,'box','off','color','none','TickDir','out','fontsize',18);
ax = gca; ax.XColor = 'black'; ax.YColor = 'black'; ax.LineWidth = 2;

%% baseline line
if doBaseline
  line([0:23],[zeros(24)],...
    'col', [0,0,0], 'LineWidth', 2,'LineStyle','--');
end

fig2svg(sprintf('images/%s_scatter.svg',fN))
