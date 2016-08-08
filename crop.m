removes = linspace(0,1,50);
rep = 1;
si = 0;
p = 5;
n = 100;
activation = zeros(n, p, length(removes));
error = zeros(p, length(removes));
Agoal = [ones(n-1,1); 2*ones(1,1)];
for k = 1:p
    filename = ['p', num2str(k), '-psd-', num2str(n),'.mat'];
    load(filename);
    period = simulation.tend;
    inum = simulation.inum;
    num_pattern = size(inum,1);
    for i =1:length(removes)
        for ind = 1:num_pattern
            [vms, spike] = generate_spike(network, synapse, simulation, inum(ind,:), si, period, rep, removes(i));
            activation(:,k,i) = activation(:,k,i)+sum(spike,2)/num_pattern;
        end
        error(k,i)=sum(activation(:,k,i));
    end
end
colors = ['b','r','g','c','m','y','w','k'];
legendInfo = cell(k,1);
figure;
for i=1:k
    plot(removes, error(i,:),colors(i),'Linewidth',2);
    hold on;
    set(gca,'fontsize',20);
    xlabel('Percentage removed', 'FontSize', 20);
    ylabel('Activation', 'FontSize', 20);
    title(['Cut off small weights'], 'FontSize', 25);
    legendInfo{i}=[num2str(i),' pattern(s)'];
end
legend(legendInfo);