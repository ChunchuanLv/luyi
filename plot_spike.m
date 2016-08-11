function plot_spike(spikes, dt, ind, varargin)
colors = ['b','r','g','c','m','y','w','k'];
[n ndt] = size(spikes);
tend = ndt*dt;
for ic=1:n
    if ~isempty(varargin)
        d = varargin{1};
        color = colors(d(ic, ind)+1);
    else
        color = colors(ind);
    end
    sp = find(spikes(ic,:));
    spy = ic+0*sp;
    plot(sp*dt,spy,'.','color', color, 'MarkerSize',25);
    hold on
end
xlabel('time (ms)','FontSize', 25);
ylabel('neuron index','FontSize', 25);
set(gca,'XLim',[0 tend]);
set(gca,'YLim',[1 n]);
set(gca,'fontsize',15);
end