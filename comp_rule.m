num_rule = 2;
networks = cell(num_rule,1);
networks{1}=load ('inh_full-psd-r1-p1-pconn0.2-100.mat', 'records', 'network', 'homeostasis', 'simulation', 'synapse');
networks{2}=load ('n100.mat', 'records', 'network');
% networks{3}=load ('psd-r3-p2-pconn0.2-100.mat', 'records', 'network');

Agoal = networks{1}.homeostasis.Agoal;
n = networks{1}.network.n;
simulation = networks{1}.simulation;
synapse = networks{1}.synapse;
inum = networks{1}.simulation.inum;
ntrial = simulation.ntrial;
[num_pattern, num_neuron] = size(inum);
tend = simulation.tend;
dt = simulation.dt;

k = 200;
errmeans = [];
errstds = [];
for i = 1:num_rule
    networks{i}.w = networks{i}.network.w;
    networks{i}.meanacts = networks{i}.records.meanacts;
    networks{i}.lastk = networks{i}.records.acts(:,:,end-k+1:end);
    networks{i}.err = sum(abs(squeeze(mean(networks{i}.lastk,1))-repmat(Agoal,1,k)),1);
    networks{i}.errmean = mean(networks{i}.err);
    networks{i}.errstd = std(networks{i}.err);
    errmeans = [errmeans networks{i}.errmean];
    errstds = [errstds networks{i}.errstd];
end



figure;
labels={'rule1'; 'rule2'; 'rule3'};
bar(errmeans);
hold on;
errorbar(errmeans,errstds,'r.');
set(gca,'xticklabel',labels);
title('bar plot of error');

figure;
for r=1:num_rule
    subplot(num_rule,1,r);
    plot_acttrace(networks{r}.meanacts);
    title(['convergence of m', num2str(r)]);
    axis([0 ntrial 0 3])
end


