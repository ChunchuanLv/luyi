num_model = 3;
models = cell(num_model,1);
models{1}=load ('50-p1-r0-inter1-n.mat', 'records', 'network', 'homeostasis', 'simulation', 'synapse');
models{2}=load ('50-p1-r1-inter1-n.mat', 'records', 'network');
models{3}=load ('50-p1-r2-inter1-n.mat', 'records', 'network');

Agoal = models{1}.homeostasis.Agoal;
ne = models{1}.network.ne;
simulaton = models{1}.simulation;
synapse = models{1}.synapse;
inum = models{1}.simulation.inum;
ntrial = simulation.ntrial;
[num_pattern, num_neuron] = size(inum);

k = 200;
errmeans = [];
errstds = [];
for i = 1:num_model
    models{i}.w = models{i}.network.w;
    models{i}.meanacts = models{i}.records.meanacts;
    models{i}.lastk = models{i}.records.acts(:,:,end-k+1:end);
    models{i}.err = sum(abs(squeeze(mean(models{i}.lastk,1))-repmat(Agoal,1,k)),1);
    models{i}.errmean = mean(models{i}.err);
    models{i}.errstd = std(models{i}.err);
    errmeans = [errmeans models{i}.errmean];
    errstds = [errstds models{i}.errstd];
end



figure;
labels={'model1'; 'model2'; 'model3'};
bar(errmeans);
hold on;
errorbar(errmeans,errstds,'r.');
set(gca,'xticklabel',labels);
title('bar plot of error');

figure;
colors = ['b','r','g','c','m','y','w','k'];
for m=1:num_model
    subplot(num_model,1,m);
    for i=1:num_pattern
        plot(models{m}.meanacts(i,:),'color',colors(i));
        hold on;
        legendInfo{i} = ['pattern ' num2str(i)];
    end
    legend(legendInfo);
    xlabel('trials')
    ylabel('mean activation')
    title(['convergence of m', num2str(m)]);
    axis([0 ntrial 0 3])
end

% compare for testing
si = 20;
rep = 10;
sps = cell(num_pattern);
for m=1:num_model
    for ind=1:num_pattern
        [vms, spike] = generate_spike(network, synapse, simulation, inum(ind,:), si, period, rep);
        sps{ind} = spike;
    end
    models{m}.sps=sps;
end
% statistics of patterns
for m=1:num_model
    sps_split = cell(num_pattern);
    num_spikes = zeros(num_pattern, rep);
    for ind=1:num_pattern
        sps_split{ind} = reshape(models{m}.sps{ind},n,period/dt,rep);
        num_spikes(ind,:) = squeeze(sum(sum(sps_split{ind})));
        models{m}.num_spikes = num_spikes;
    end
end
