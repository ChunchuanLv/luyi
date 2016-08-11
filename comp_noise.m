num = 3;
networks = cell(num,1);
networks{1}=load ('p1-psd-100.mat', 'records', 'network', 'homeostasis', 'simulation', 'synapse');
networks{2}=load ('p1-psd-100-si10.mat', 'records', 'network');
networks{3}=load ('p1-psd-100-si20.mat', 'records', 'network');

Agoal = networks{1}.homeostasis.Agoal;
n = networks{1}.network.n;
simulation = networks{1}.simulation;
synapse = networks{1}.synapse;
inum = networks{1}.simulation.inum;
ntrial = simulation.ntrial;
[num_pattern, num_neuron] = size(inum);
tend = simulation.tend;
dt = simulation.dt;

% compare for testing
si = 10;
rep = 100;
period = tend;
remove = 0;
sps = cell(num_pattern);
for r=1:num
    for ind=1:num_pattern
        [vms, spike] = generate_spike(networks{r}.network, synapse, simulation, inum(ind,:), si, period, rep, remove);
        sps{ind} = spike;
    end
    networks{r}.sps=sps;
end
% statistics of patterns
for r=1:num
    sps_split = cell(num_pattern);
    num_spikes = zeros(num_pattern, rep);
    for ind=1:num_pattern
        sps_split{ind} = reshape(networks{r}.sps{ind},n,period/dt,rep);
        num_spikes(ind,:) = squeeze(sum(sum(sps_split{ind})));
        networks{r}.num_spikes = num_spikes;
    end
end
% statistics of patterns
means = [];
stds = [];
labels = {'Trained without noise','Trained with noise 10', 'Trained with noise 20'};
for r=1:num
    means = [means; mean(networks{r}.num_spikes,2)];
    stds = [stds; std(networks{r}.num_spikes,0,2)];
end
figure;
bar(means);
set(gca,'xticklabel',labels,'Fontsize',20);
hold on;
errorbar(means, stds,'r.');
title('Bar plot of spikes','Fontsize',25);
set(gca,'Fontsize',20);