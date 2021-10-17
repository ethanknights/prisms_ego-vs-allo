
function plot_OL_errorBar(fN,yLim)

t = readtable(sprintf('csv/%s.csv',fN));

close all
subs = unique(t.ID_num);
% nSubs = length(subs);
tmpD = table2array(t(:,3:end));
nSess = size(tmpD,2);
nSEMs = 2;

%pGColour = {'red','blue'};
%cMapCol = lbmap(2,'BrownBlue'); %red left, blue Right
%cMapCol = [0 1 0; 0 1 1]; %green L, Blue R
cMapCol = ... %better grayscale visibility
  [0.4940 0.1840 0.5560; 0.3010 0.7450 0.9330]; %purple left, blue right

figure('position',[0,0,1000,1000])
%% Left prism group
pG = 1; doErrorBars(t,pG,cMapCol,nSEMs);
%% Right prism group
pG = 2; doErrorBars(t,pG,cMapCol,nSEMs)

%% other plot formatting
title('Open Loop Pointing');
xlabel('Session'); xlim([0.6 5.6]); set(gca,'XTick',[1:1:5]);
xticklabels({'Pre-Sham','Post-Sham','Pre-Prism','Post-Prism','Late-Prism'});
xtickangle(90);
ylim([yLim(1) - 0, yLim(2) + 0]); ylabel('Endpoint Error (mm)');
set(gca,'box','off','color','none','TickDir','out','fontsize',18);
ax = gca; ax.XColor = 'black'; ax.YColor = 'black'; ax.LineWidth = 2;

fig2svg(sprintf('images/%s_errorBar.svg',fN))

%% Functions
%% ------------------------------------------------------------------------
  function doErrorBars(t,pG,cMapCol,nSEMs)
    
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
%% ------------------------------------------------------------------------
end
