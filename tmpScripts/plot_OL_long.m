%% Old version (trying to stik with long)
function plot_OL_long(t)

close all

subs = unique(t.subNum);
nSubs = length(subs);
%pGColour = {'red','blue'};
cMapCol = lbmap(2,'RedBlue'); %red left, blue Right
%cMapCol = [0 1 0; 0 1 1]; %green L, Blue R


figure('position',[0,0,1000,1000])

for s = 1:nSubs
  
  idx_sub = t.subNum == s;
  pG = unique(t.PrismGroup(idx_sub));
  
  for sess = 1:5
    
    idx_sess = t.Session == sess;
    
    idx = all( [ idx_sub, idx_sess], 2);
    d(s,sess) = mean(t.Errorinmm(idx));
    
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

%export_fig 'images/OL_matlab.tiff' -transparent
fig2svg('images/OL_matlab.svg')


