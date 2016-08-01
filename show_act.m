spike_rec = records.spike_rec;
dt = simulation.dt;
tend = simulation.tend;
inum = simulation.inum;
interval = simulation.interval;
[num n ndt] = size(spike_rec);
[num_pattern, num_inj] = size(inum);
k=figure;
axis([0 tend 1 n]);
xlabel('time (ms)')
ylabel('neuron index')
axis([0 tend 1 n])
box on

colors = ['b','r','g','c','m','y','w','k'];
colors = colors(1:num_pattern);
for j = 0:floor(num/interval)-1
    for i=1:interval
        plot_spike(squeeze(spike_rec(j*interval+i,:,:)), dt, colors(mod(j,num_pattern)+1));
        hold on;
        box on;
        if i+j>num
            break;
        end
        t = sprintf('raster plot of trial: %d', j*interval+i);
        title(t);
        F(j+1) = getframe(k);
        clf;
    end
end
% f=figure;
% movie(f,F,1,3);
close;