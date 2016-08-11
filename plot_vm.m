% load('inh_rand-psd-r1-p1-pconn0.2-100.mat','records','simulation');
tend = simulation.tend;
dt = simulation.dt;
vthr = synapse.vthr;
vreset=synapse.vreset;
t = linspace(0,tend,tend/dt);
figure;
subplot(2,1,1);
plot(t, records.vm_rec(99,:), 'Linewidth',2);
xlabel('time (ms)','FontSize', 17)
ylabel('Vm (mV)','FontSize', 17)
title('Membrane voltage of neuron 99','FontSize', 17)
set(gca,'XLim',[0 tend]);
set(gca,'YLim',[vreset vthr]);
set(gca,'fontsize',15);
subplot(2,1,2);
plot(t, records.vm_rec(45,:),'Linewidth',2);
xlabel('time (ms)','FontSize', 17)
ylabel('Vm (mV)','FontSize', 17)
title('Membrane voltage of neuron 45','FontSize', 17)
set(gca,'XLim',[0 tend]);
set(gca,'YLim',[vreset vthr]);
set(gca,'fontsize',15);