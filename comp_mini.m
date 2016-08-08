figure;
remove = 0;
period=30;
rep = 1;
si = 0;
k = 1;
for i = 1:2
    load(['mininet', num2str(i), '.mat']);
    inum = simulation.inum;
    dt=simulation.dt;
    w = network.w;
    num_pattern = size(inum,1);
    subplot(2,2,k);
    k = k+1;
    for ind = 1:num_pattern
        [vms, spike] = generate_spike(network, synapse, simulation, inum(ind,:), si, period, rep, remove);
        plot_spike(spike, dt, ind)
        set(gca, 'Fontsize',25);
        title(['Number of patterns: ', num2str(i)], 'Fontsize',25);
    end
    subplot(2,2,k);
    plotw(w);
    k = k+1;
end
