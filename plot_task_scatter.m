function [d] = plot_task(t,taskStr)

close all

subs = unique(t.subNum);
nSubs = length(subs);
%pGColour = {'red','blue'};
cMapCol = lbmap(2,'RedBlue');
%cMapCol = [0 1 0; 0 1 1]; %green L, Blue R


figure('position',[0,0,1000,1000])

for s = 1:nSubs
  
  idx_sub = t.subNum == s;
  pG(s) = unique(t.PrismGroup(idx_sub));
  
  %% Sham
  
  for sess = 1:2
    idx_sess = t.Session == sess;
    idx = all( [ idx_sub, idx_sess], 2);
  
    d(s,sess) = mean(t.ErrorInMm(idx));
  end
  
  plot(d(s,:),...
    '-o','Color',cMapCol(pG(s),:), ...
    'LineWidth',2,'LineStyle','--', ...
    'MarkerSize',18,'MarkerFaceColor',cMapCol(pG(s),:),'MarkerEdgeColor','black')
  hold on
end


%% other plot formatting
title(sprintf('%s - Accuracy',taskStr),'Interpreter', 'none');
xlabel(['Session']);
xlim([0 3]); set(gca,'XTick',[1:1:3]);
xticklabels({'Pre-Prism','Post-Prism'});
xtickangle(45)

tmpLim = ylim;
%ylim([tmpLim(1) - 0, tmpLim(2) + 0])
ylim([-85,85])
ylabel('Endpoint Error (mm)')

set(gca,'box','off','color','none','TickDir','out','fontsize',18);

%eval(sprintf('export_fig images/%s_matlab.tiff -transparent',taskStr))
fig2svg(sprintf('images/%s_matlab.svg',taskStr))

%% add prism group to d for later
d(:,3) = pG;


