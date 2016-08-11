spike_rec = records.spike_rec;
dt = simulation.dt;
tend = simulation.tend;
inum = simulation.inum;
interval = simulation.interval;
[num, n, ndt] = size(spike_rec);
[num_pattern, num_inj] = size(inum);
k=figure;
axis([0 tend 1 n]);
xlabel('time (ms)')
ylabel('neuron index')
axis([0 tend 1 n])
box on

for j = 0:floor(num/num_pattern)-1
    for i=1:num_pattern
        plot_spike(squeeze(spike_rec(j*num_pattern+i,:,:)), dt, mod(i,num_pattern)+1);
        hold on;
        box on;
        if i+j>num
            break;
        end
        t = sprintf('raster plot of trial: %d', j*interval+i);
        title(t);
    end
    F(j+1) = getframe(k);
    clf;
end
% f=figure;
% movie(f,F,1,3);
close;