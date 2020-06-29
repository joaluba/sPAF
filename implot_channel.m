function implot_channel(m3,ch,vT,vP)
imagesc(squeeze(m3(ch,:,:)))
xlabel('time [s]');xticks(1:10:length(vT));
xticklabels(round(vT(1:10:end)*100)/100);xtickangle(45);
ylabel('period [s]');yticks(1:20:length(vP));yticklabels(round(vP(1:20:end)*100*100)/100);
title(['freq. channel ', num2str(ch)])
colorbar;
end