function plot_acttrace(meanacts)
colors = ['b','r','g','c','m','y','w','k'];
num_pattern = size(meanacts,1);
for i=1:num_pattern
    plot(meanacts(i,:),'color',colors(i), 'Linewidth', 2);
    hold on;
    legendInfo{i} = ['pattern ' num2str(i)];
end
legend(legendInfo,'Location','northwest');
xlabel('trials', 'Fontsize', 25)
ylabel('mean activation', 'Fontsize', 25)
set(gca, 'Fontsize',20);
end