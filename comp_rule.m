num_rule = 3;
networks = cell(num_rule,1);
networks{1}=load ('psd-r1-p2-pconn0.2-100.mat', 'records', 'network', 'homeostasis', 'simulation', 'synapse');
networks{2}=load ('psd-r2-p2-pconn0.2-100.mat', 'records', 'network');
networks{3}=load ('psd-r3-p2-pconn0.2-100.mat', 'records', 'network');

Agoal = networks{1}.homeostasis.Agoal;
ne = networks{1}.network.ne;
simulaton = networks{1}.simulation;
synapse = networks{1}.synapse;
inum = networks{1}.simulation.inum;
ntrial = simulation.ntrial;
[num_pattern, num_neuron] = size(inum);

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

% compare for testing
si = 20;
rep = 10;
sps = cell(num_pattern);
for r=1:num_rule
    for ind=1:num_pattern
        [vms, spike] = generate_spike(network, synapse, simulation, inum(ind,:), si, period, rep);
        sps{ind} = spike;
    end
    networks{r}.sps=sps;
end
% statistics of patterns
for r=1:num_rule
    sps_split = cell(num_pattern);
    num_spikes = zeros(num_pattern, rep);
    for ind=1:num_pattern
        sps_split{ind} = reshape(networks{r}.sps{ind},n,period/dt,rep);
        num_spikes(ind,:) = squeeze(sum(sum(sps_split{ind})));
        networks{r}.num_spikes = num_spikes;
    end
end
