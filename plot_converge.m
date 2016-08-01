n=network.n;
meanact=homeostasis.meanact;
meanacts = records.meanacts;
meanavAct=homeostasis.meanavAct;
Agoal=homeostasis.Agoal;
aA=homeostasis.aA; aw=homeostasis.aw;
inum = simulation.inum;
num_pattern = size(inum,1);

ntrial=simulation.ntrial;

figure;
subplot(2,1,1);
plot(meanact, 'r')
hold on
plot(meanavAct,'g')
hold on
plot(ones(ntrial)*mean(Agoal), 'b');
legend('mean activations per trial', 'overall mean activation',...
      'target activation')
t1=sprintf('averaged spike number (aA=%.2f, aw=%.2f)', aA, aw);
title(t1)
xlabel('trials')
ylabel('number of spikes')
colors = ['b','r','g','c','m','y','w','k'];
subplot(2,1,2);
for i=1:num_pattern
    plot(meanacts(i,:),'color',colors(i));
    hold on;
    legendInfo{i} = ['pattern ' num2str(i)];
end
legend(legendInfo);
title('mean acts of each patter')
xlabel('trials')
ylabel('mean activation')