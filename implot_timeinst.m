function implot_timeinst(m3,t,vfc,vP)
imagesc(squeeze(m3(:,:,t))')
xlabel('center frequency [Hz]');xticks(1:23);xticklabels(vfc);xtickangle(45);
ylabel('period [s]');yticks(1:20:length(vP));yticklabels(round(vP(1:20:end)*100*100)/100);
title(['time instance ', num2str(t)])
colorbar;
end