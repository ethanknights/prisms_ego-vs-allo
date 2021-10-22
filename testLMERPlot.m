rawD = readtable('results/test.csv');
d= rawD;

cMapCol = ... %better grayscale visibility
  [0.4940 0.1840 0.5560; 0.3010 0.7450 0.9330]; 

clf
%left prism group
x=[1:2] -0.1;
errorbar(x,d.emmean(1:2),d.SE(1:2),'color',cMapCol(1,:),...
  'LineWidth',2,'LineStyle','-','Capsize',40,...
       'marker','o','markersize',10,'markerfacecolor','black') %propoint
hold on
errorbar(x,d.emmean(3:4),d.SE(3:4),'color',cMapCol(1,:),...
  'LineWidth',2,'LineStyle','--','Capsize',40,...
       'marker','o','markersize',10,'markerfacecolor','black') %antipoint

hold on

%right prism group (cyan)
x=[1:2];
errorbar(x,d.emmean(5:6),d.SE(5:6),'color',cMapCol(2,:), ...
  'LineWidth',2,'LineStyle','-','Capsize',40,...
       'marker','o','markersize',10,'markerfacecolor','black') %propoint
hold on
errorbar(x,d.emmean(7:8),d.SE(7:8),'color',cMapCol(2,:),...
  'LineWidth',2,'LineStyle','--','Capsize',40,...
       'marker','o','markersize',10,'markerfacecolor','black') %antipoint

title('Task * Session * Prism Group (SE+/-1) (solid/dashed = pro/antipoint)', 'Interpreter','none')
xlabel('Session'); xlim([0.6 2.4]); set(gca,'XTick',[1:1:3]);
ylabel('Absolute Error (mm)')

titleStr = 'LMERinteraction_taskBYsessionBYprismgroup';
varStr = 'absErr';
eval(...
  sprintf(...
  'export_fig ''images/%s_variable-%s_scatter.tiff'' -transparent',...
  titleStr,varStr)...
  )
