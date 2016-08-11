close all;
seed = 0;
%%%% neuron parameters ,time in ms%%%
% note full LB model has AHP, synaptic depression, noise,
% markov synapse
n = 1;
vrest	= -60;
vreset 	= -60;
vthr	= -50;
taumE 	= 30;
tauminv = 1/taumE;
rm		= 1; % input res. NOT USED
si      = 20; % noise

trefr	= 1;
% simulation parameters
tend	= 50; % trial time msec
dt		= 0.1; % smaller would be better
ndt		= round(tend/dt);
% simulate
tmin = 0; % don't measure spikes before tmin
ntmin = round(tmin/dt);

period = 25;
rep = 1;
inum = 1;
stimampl =25;
ind = 1;
op = 'constant';
istim = istimuli(n, period, rep, tend, dt, inum(ind,:), stimampl, op);
vm = vrest;
vm_rec = zeros(ndt,1);
vm_rec(1) = vm;

spikes = zeros(ndt,1);             % binary array of spikes vs time
lastspiketime = -1000;  % time since last spike, for refractoriness
sptimes = zeros(round(tend),1);
nsp = 0;               % # spikes for each neuron

for idt=1:ndt-1
    t = idt*dt;
    vmnext = vm + dt*tauminv*(vrest-vm+istim(:,idt)+si*randn());
    vm_rec(idt+1) = vmnext;

    refr = find(lastspiketime > t-trefr);
    vmnext(refr) = vreset;

    if vmnext > vthr
        spikes(idt+1) = 1*(t>tmin);
        vmnext = vreset;
        lastspiketime = t;
        if (t>tmin)
            nsp = nsp + 1;
            sptimes(nsp) = t;
        end
    end
    vm=vmnext;
end
figure;
x = linspace(0,tend,ndt);
subplot(3,1,1);
plot(x,istim, 'm','Linewidth',3);
xlabel('time (ms)','FontSize', 20);
ylabel('current (mA)','FontSize', 20);
set(gca,'fontsize',20)
set(gca,'xlim',[0 tend])
title('External current Iext','FontSize', 20);
subplot(3,1,2);
plot(x,vm_rec, 'r','Linewidth',3);
hold on;
plot(x, vthr*ones(length(vm_rec)),'g','Linewidth',3);
hold on;
legend('Vm', 'Vthr');
xlabel('time (ms)','FontSize', 20);
ylabel('voltage (mV)','FontSize', 20);
title('Membrane voltage Vm','FontSize', 20);
set(gca,'fontsize',20)
set(gca,'xlim',[0 tend])
subplot(3,1,3);
plot(x, spikes,'b','Linewidth',3);
xlabel('time (ms)','FontSize', 20);
ylabel('number of spikes','FontSize', 20);
title('Spike train of neuron','FontSize', 20);
set(gca,'fontsize',20)
set(gca,'xlim',[0 tend])
set(gca,'ytick',[0 1])


