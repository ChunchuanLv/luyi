clear all;
close all;
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
tend	= 200; % trial time msec
dt		= 0.1; % smaller would be better
ndt		= round(tend/dt);
% simulate
tmin = 0; % don't measure spikes before tmin
ntmin = round(tmin/dt);

period = 100;
rep = 1;
inum = 1;
stimampl = 12;
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
plot(x,istim, 'y');
xlabel('time (ms)');
ylabel('current (mA)');
set(gca,'xlim',[0 tend])
title('external current Iext');
subplot(3,1,2);
plot(x,vm_rec, 'r');
hold on;
plot(x, vthr*ones(length(vm_rec)),'g');
hold on;
legend('Vm', 'Vthr');
xlabel('time (ms)');
ylabel('voltage (mV)');
title('membrane voltage Vm');
set(gca,'xlim',[0 tend])
subplot(3,1,3);
plot(x, spikes,'b');
xlabel('time (ms)');
ylabel('number of spikes');
title('spike train of neuron');
set(gca,'xlim',[0 tend])
set(gca,'ytick',[0 1])


