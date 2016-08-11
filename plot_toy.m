load toy;
vm_rec = records.vm_rec;
tend = simulation.tend;
w = network.w;
dt = simulation.dt;
ndt = tend/dt;
n = network.n;
% figure;
% x = linspace(0,tend,ndt);
% for i=1:n
%     subplot(n,1,i);
%     plot(x, vm_rec(i,:));
%     set(gca,'fontsize',15)
%     hold on;
%     xlabel('time (ms)', 'FontSize', 17)
%     ylabel('Vm (mV)', 'FontSize', 17)
%     title(['mebrane voltage of neuron ', num2str(i)], 'FontSize', 17)
% end
% figure;
% for i=1:n
%     subplot(n,2,2*i-1);
%     plot(x, ge_rec(i,:));
%     hold on;
%     set(gca,'fontsize',15)
%     xlabel('time (ms)', 'FontSize', 17)
%     ylabel('Ge', 'FontSize', 17)
%     title(['Ge of neuron ', num2str(i)], 'FontSize', 17)
%     subplot(n,2,2*i);
%     plot(x, gi_rec(i,:));
%     hold on;
%     set(gca,'fontsize',15)
%     xlabel('time (ms)', 'FontSize', 17)
%     ylabel('Gi', 'FontSize', 17)
%     title(['Gi of neuron ', num2str(i)], 'FontSize', 17)
% end


figure;
plotw(w);
title('weight matrix','FontSize', 17)
set(gca,'fontsize',15)
figure;
for i=1:n
    subplot(n,1,i)
    plot(x,spikes(i,:))
    set(gca,'xlim',[0 tend])
    set(gca,'ytick',[0 1])
    set(gca,'fontsize',15)
    xlabel('time (ms)', 'FontSize', 17);
    ylabel('number', 'FontSize', 17);
    title(['spike of neuron ', num2str(i)], 'FontSize', 17);
    hold on
end