figure;
interval = [2 3 4 5];
for i = 1:4
    subplot(2,2,i);
    load(['tp',num2str(interval(i)),'decay-psd-r1-100.mat']);
    plot_acttrace(records.meanacts)
    set(gca, 'Fontsize',25);
    title(['Number of patterns: ', num2str(interval(i))], 'Fontsize',25);
end