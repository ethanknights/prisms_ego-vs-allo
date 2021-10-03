for i = 1:length(idx_L); newRow_L(i,outCol) = cell2mat( tmpD(idx_L(i), colIdx) ); end
for i = 1:length(idx_C); newRow_C(i,outCol) = cell2mat( tmpD(idx_C(i), colIdx) ); end
for i = 1:length(idx_R); newRow_R(i,outCol) = cell2mat( tmpD(idx_R(i), colIdx) ); end