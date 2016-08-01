function plot_spike(spikes, dt, varargin)
if isempty(varargin)
    color='b';
else
    color=varargin{1};
end
[n ndt] = size(spikes);
tend = ndt*dt;
for ic=1:n
    sp = find(spikes(ic,:));
    spy = ic+0*sp;
    plot(sp*dt,spy,'.','color',color);
    hold on
end
xlabel('time (ms)')
ylabel('neuron index')
axis([0 tend 1 n])
end