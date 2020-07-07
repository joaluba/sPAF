function implot_timeinst(m3,t,vfc,vP)
A=squeeze(m3(:,:,t))';
A(~nonzeros(A))=nan;
imagesc(A);
xlabel('center frequency [Hz]');xticks(1:23);xticklabels(vfc);xtickangle(45);
ylabel('period [s]');yticks(1:20:length(vP));yticklabels(round(vP(1:20:end)*1000)/1000);
title(['time instance ', num2str(t)]);
colorbar;
grid on
cmap = [1 1 1; parula];
colormap(cmap);
colorbar;
end