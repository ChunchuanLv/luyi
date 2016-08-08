w_active = network.w_active;
inum = simulation.inum;
dt=simulation.dt;

si = 20;
period = 50;
rep = 1;

remove = 0;
d = deg_sep(network.w_active);
num_pattern = size(inum,1);
for ind = 1:num_pattern
    [vms, spike] = generate_spike(network, synapse, simulation, inum(ind,:), si, period, rep, remove);
end

figure;
colors = ['b','r','g','c','m','y','w','k'];
[n ndt] = size(spike);
tend = ndt*dt;
subplot(2,1,1);
for ic=1:n
    sp = find(spike(ic,:));
    spy = ic+0*sp;
    if sp~=0
        color = colors(d(ic,inum(ind,:))+1);
    end
    shape = '.';
    if ic == 1
        shape = 'h';
    elseif w_active(ic,end)==1
        shape = '*';
    end
    plot(sp*dt,spy, shape,'color',color,'MarkerSize',11);
    hold on
end
xlabel('time (ms)','FontSize', 17)
ylabel('neuron index','FontSize', 17)
title('Spike sequence under noise','FontSize', 17)
set(gca,'XLim',[0 tend]);
set(gca,'YLim',[1 n]);
set(gca,'fontsize',15);
subplot(2,1,2);
maps = cell(num_pattern,1);
for p = 1:num_pattern
    maps{p}=plot_sorted(spike, period, dt, n, ne, colors(p), maps{p});
    hold on;
end
title('Sorted spike sequence','FontSize', 17);
xlabel('time (ms)','FontSize', 17);
ylabel('sorted index','FontSize', 17);
set(gca,'xLim',[0 period]);
set(gca,'fontsize',15);