w = network.w;
inum = simulation.inum; stimampl=simulation.stimampl;
idelay = simulation.idelay;
vrev_e=synapse.vrev_e; vrev_i=synapse.vrev_i;
tau_e=synapse.tau_e; tau_i=synapse.tau_i;
tauminv=synapse.tauminv;
trefr=synapse.trefr;
vreset=synapse.vreset; vrest=synapse.vrest;
vthr=synapse.vthr;
n=network.n; ne=network.ne;
dt=simulation.dt;

si = 0;
period = 50;
rep = 1;

tend	= rep*period; % trial time msec
ndt		= round(tend/dt);
op = 'delta';
% create separate excit and inhib matrices
we = max(w,0);
wi = -min(w,0);

num_pattern = size(inum, 1);
sps = cell(num_pattern, 1);
vm = vrest*ones(n,1);
vm_rec = cell(num_pattern, 1);
for ind = 1:num_pattern
    vm = vrest*ones(n,1);
    
    lastspiketime = -1000*ones(1,n);  % time since last spike, for refractoriness
    nsp = zeros(n,1);               % # spikes for each neuron
    rep_num = 0;
    [vms, spike] = generate_spike(network, synapse, simulation, inum(ind,:), si, period, rep);
    vm_rec{ind} = vms;
    sps{ind} = spike;
end

for i=1:num_pattern
    fprintf('average number of spikes for pattern %d is %.2f\n', i, sum(sps{i}(:))/rep);
end

% raster plot
figure;
colors = ['b','r','g','c','m','y','w','k'];
for i=1:num_pattern
    plot_spike(sps{i}, dt, colors(i));
    hold on;
    legendInfo{i} = num2str(sum(sps{i}(:)));
end

legend(legendInfo);
plot(linspace(0,tend, ndt+1),ne, 'r')
title('raster plot of the last trial')
xlabel('time (ms)')
ylabel('neuron index')
set(gca,'xtick',(0:period:tend))

% statistics of patterns
sps_split = cell(num_pattern, 1);
num_spikes = zeros(num_pattern, rep);
for i=1:num_pattern
    sps_split{i} = reshape(sps{i},n,period/dt,rep);
    num_spikes(i,:) = squeeze(sum(sum(sps_split{i})));
end

means = mean(num_spikes,2);
stds = std(num_spikes,0,2);
figure;
bar(means);
hold on;
errorbar(means, stds,'r.');
title('bar plot of spikes');

% sorted spike sequence
figure;
maps = cell(num_pattern,1);
colors = ['b','r','g','c','m','y','w','k'];
for p = 1:num_pattern
    maps{p}=plot_sorted(sps{p}, period, dt, n, ne, colors(p), maps{p});
    hold on;
end
title('sorted spike sequence')
xlabel('time (ms)')
set(gca,'xtick',(0:period:tend))

% dist = 0;
% dist2 = 0;
% dist3 = 0;
% tc = 0.1;
% kerneltype = 0;
% for i = 0:rep-1
%     for j = 0:rep-1
%         dist = dist + spike_dist(spike1(:,i*period/dt+1:(i+1)*period/dt),...
%             spike2(:,j*period/dt+1:(j+1)*period/dt), dt, tc, kerneltype)/((rep^2)/2);
%     end
% end
% for i = 0:rep-2
%     for j = i+1:rep-1
%         dist2 = dist2 + spike_dist(spike1(:,i*period/dt+1:(i+1)*period/dt),...
%             spike1(:,j*period/dt+1:(j+1)*period/dt), dt, tc, kerneltype)/(((rep-1)*rep)/2);
%     end
% end
% for i = 0:rep-2
%     for j = i+1:rep-1
%         dist3 = dist3 + spike_dist(spike2(:,i*period/dt+1:(i+1)*period/dt),...
%             spike2(:,j*period/dt+1:(j+1)*period/dt), dt, tc, kerneltype)/(((rep-1)*rep)/2);
%     end
% end
% fprintf('averaged distance between spike train 1 and spike train 2 is %.3f\n', dist);
% fprintf('averaged distance between spike train 1 is %.3f\n', dist2);
% fprintf('averaged distance between spike train 2 is %.3f\n', dist3);
av_vm = cell(num_pattern,1);
for ind = 1:num_pattern
    av_vm{ind} = zeros(n, period/dt);
    for i=0:rep-1
        av_vm{ind} = av_vm{ind} + vm_rec{ind}(:,i*period/dt+1:(i+1)*period/dt)/rep;
    end
end