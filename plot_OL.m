clear; close all
t = readtable('csv/data_openloop.csv');

subs = unique(t.subNum);
nSubs = length(subs);
%pGColour = {'red','blue'};
cMapCol = lbmap(2,'RedBlue');
%cMapCol = [0 1 0; 0 1 1]; %green L, Blue R


figure

for s = 1:nSubs
  
  idx_sub = t.subNum == s;
  pG = unique(t.PrismGroup(idx_sub));
  
  for sess = 1:5
    
    idx_sess = t.Session == sess;
    
    idx = all( [ idx_sub, idx_sess], 2);
    d(s,sess) = mean(t.ErrorInMm(idx));
    
  end
  
  plot(d(s,:),...
    '-o','Color',cMapCol(pG,:), ...
    'LineWidth',2,'LineStyle','--', ...
    'MarkerSize',18,'MarkerFaceColor',cMapCol(pG,:),'MarkerEdgeColor','black')
  hold on
end


%% other plot formatting
title('Open Loop Pointing - Accuracy');
xlabel(['Session']);
xlim([0 6]); set(gca,'XTick',[1:1:5]);
xticklabels({'Pre-Sham','Post-Sham','Pre-Prism','Post-Prism','Late-Prism'});
xtickangle(90)

tmpLim = ylim;
ylim([tmpLim(1) - 0, tmpLim(2) + 0])
ylabel('Endpoint Error (mm)')

set(gca,'box','off','color','none','TickDir','out','fontsize',18);



