function plot_acttrace(meanacts)
colors = ['b','r','g','c','m','y','w','k'];
figure;
num_pattern = size(meanacts,1);
for i=1:num_pattern
    plot(meanacts(i,:),'color',colors(i));
    hold on;
    legendInfo{i} = ['pattern ' num2str(i)];
end
legend(legendInfo);
title('mean acts of each pattern')
xlabel('trials')
ylabel('mean activation')
end