clear;
seed=1;
rng(seed);
n=10;  % total # neurons
ne=n-1; % # excitatory neurons
ni=1;

%note, index such that neurons 1..ne are excitatory.
idxE=zeros(n,1);
idxE(1:ne)=1;
idxI=zeros(n,1);
idxI(ne+1:n)=1;

%%%% neuron parameters ,time in ms%%%
% note full LB model has AHP, synaptic depression, noise,
% markov synapse
vrest	= -60;
vreset 	= -60;
vthr	= -50;
taumE 	= 30;
taumI   = 10;
tauminv = 1./(idxE*taumE+idxI*taumI);
rm		= 1; % input res. NOT USED


%%%%synapse parameters %%%
vrev_e 	= 0;
vrev_i 	= -60;
tau_e	= 5;
tau_i	= 5;

trefr	= 1;
wexc	= 40/ne/tau_e; % note different vrev
winh	= 200/ni/tau_i; %>0

% homeostasis parameters
AgoalE  = 1;
AgoalI  = 2;
Agoal   = idxE*AgoalE+idxI*AgoalI; % (col. vector)
aA      = 0.05; %update amount per trials.
aw      = 0.05;

% simulation parameters
tend	= 50; % trial time msec
dt		= 0.1; % smaller would be better
ndt		= round(tend/dt);

% create weight matrix index, w_{post,pre}
% TODO: randomize
w = zeros(n,n);
w_active = zeros(n,n);
for i=1:ne-1
    w_active(i,i+1)=1;
    w_active(i+1,i)=1;
end
for i=1:ne
    w_active(i,ne+1:end)=1;
    w_active(ne+1:end,i)=1;
end

for j=1:n
    if (j>ne)
        w(1:ne,j) = -winh*w_active(1:ne,j);
    else
        w(:,j) = wexc*w_active(:,j);
    end
end


w = w-diag(diag(w)); % exclude self-coupling
% create separate excit and inhib matrices
we = max(w,0);
wi = -min(w,0);

% pstim=0.2; % prob of neurons connected to stimulus
stimampl = 5000;
si = 0; % noise

inum = [1];
[num_pattern, col] = size(inum);

% for i = 1:num_pattern
%     inum = [inum; (col-1)*i-1:(col-1)*i+1];
% end
pconn = (3.5*n-1)/(n^2-n);
fprintf('num_stimuli=%d, num_neurons=%d, connectivity=%.2f, aA=%.3f, aw=%.3f\n',...
    num_pattern, n, pconn, aA, aw);

% simulate
tmin = 0; % don't measure spikes before tmin
ntmin = round(tmin/dt);

delay = 2;
idelay = round(delay/dt);

avAct = zeros(n,1);
op = 'delta';
c = 0;

period = tend;
rep = 1;
interval = 1;
disp = 100;
ind = 1;
av_err = 0;
av_dw = 0;
trial = 10000;
ntrial = trial*num_pattern;
spike_rec = zeros(round(ntrial),n,ndt);
w_rec = zeros(round(ntrial),n,n);
dw_rec = zeros(round(ntrial),n,n);
meanacts = zeros(num_pattern,trial);
meanact = zeros(ntrial,1);
acts = zeros(num_pattern,n,trial);
act = zeros(n, ntrial);
meanavAct = zeros(ntrial,1);
for itrial=1:ntrial
    % Initialize variables at start of trial
    if mod(itrial, interval)==0
        ind = mod(c, num_pattern)+1;
        c = c+1;
    end
    istim = istimuli(n, period, rep, tend, dt, inum(ind,:), stimampl, op);
    vm = vrest*ones(n,1);
    
    ge = zeros(n,ndt);
    gi = zeros(n,ndt);
    
    %record of voltage and conductance
    vm_rec = zeros(n, ndt);
    vm_rec(:,1) = vm;
    ge_rec = zeros(n, ndt);
    gi_rec = zeros(n, ndt);
    
    spikes = zeros(n,ndt);             % binary array of spikes vs time
    lastspiketime = -1000*ones(1,n);  % time since last spike, for refractoriness
    sptimes = zeros(n,round(tend*10e-3));
    nsp = zeros(n,1);               % # spikes for each neuron
    
    for idt=1:ndt-1
        t = idt*dt;
        
        itdel = max(1,idt-idelay);
        
        % synaptic input currents
        ie = ge(:,itdel).*(vrev_e-vm);
        ii = gi(:,itdel).*(vrev_i-vm);
        
        if idt-idelay<1
            ie = 0;
            ii = 0;
        end
        
        vmnext = vm + dt*tauminv.*(vrest-vm+istim(:,idt)+ie+ii+si*randn(n,1));
        % record of voltage and conductance
        vm_rec(:,idt+1) = vmnext;
        ge_rec(:,idt) = ge(:,idt);
        gi_rec(:,idt) = gi(:,idt);
        
        refr = find(lastspiketime > t-trefr);
        vmnext(refr) = vreset;
        
        sp=(vmnext > vthr); % vector with spikes
        spi = find(sp); % indices
        
        if (size(spi)>0)
            spikes(spi,idt+1) = 1*(t>tmin);
            vmnext(spi) = vreset;
            lastspiketime(spi) = t;
            for j=1:length(spi)*(t>tmin)
                k = spi(j);
                nsp(k) = nsp(k)+1;
                sptimes(k,nsp(k)) = t;
            end
            ge(:,idt) = ge(:,idt)+we*sp;
            gi(:,idt) = gi(:,idt)+wi*sp;
        end
        
        ge(:,idt+1) = ge(:,idt)*(1-dt/tau_e);
        gi(:,idt+1) = gi(:,idt)*(1-dt/tau_i);
        vm=vmnext;
    end

%     dw = aw*we.*((Agoal-avAct)*(avAct)').*1./(wexc/max(we(:))+repmat(avAct,1,n));
    dw = aw*we.*((Agoal-avAct)*avAct');
    
    we = we+dw;
    we = max(we,0);
    
%     w = w+dw;
%     we = max(0, w);
%     wi = -min(0, w);
    % note without any activity, no homeostasis...
    % wi is likely fixed, as in Buonomano JNP 2005
    act(:,itrial) = sum(spikes')';
    avAct = avAct+aA*(act(:,itrial)-avAct); % vector with average activities
    meanact(itrial) = mean(act(:,itrial));
    meanacts(ind,floor((itrial-1)/interval/num_pattern)*interval+mod(itrial-1,interval)+1) = meanact(itrial);
    acts(ind,:,floor((itrial-1)/interval/num_pattern)*interval+mod(itrial-1,interval)+1) = act(:,itrial);
    meanavAct(itrial) = mean(avAct);
    av_err = av_err + sum(abs(Agoal-avAct))/disp;
    av_dw = av_dw + norm(dw)/disp;
    if mod(itrial, disp) == 0
        fprintf('trial: %d/%d \t error=%.4f \t |dw|=%.4f \t inactive=%.2f\n',...
            itrial, ntrial, av_err, av_dw, sum(avAct<0.5)/n);
%         if av_err < 10e-5 && av_dw < 10e-5
%             fprintf('converged\n');
%             spike_rec=spike_rec(1:itrial,:,:);
%             w_rec = w_rec(1:itrial,:,:);
%             dw_rec = dw_rec(1:itrial,:,:);
%             break;
%         end
        av_err = 0;
        av_dw = 0;
    end
    %record training process
    spike_rec(itrial,:,:)=spikes;
    w_rec(itrial,:,:) = we;
    dw_rec(itrial,:,:) = dw;
end

sumrate = mean(spikes)/dt*1e3;
sumrate2 = mean(spikes);
if (ne>0)
    excrate = mean(spikes(1:ne,:))/dt*1e3;
end
if (ni>0)
    inhrate = mean(spikes(ne+1:n,:))/dt*1e3;
end

avrate = mean(sumrate);
if (ne>0)
    avexcrate = mean(excrate);
end
if (ni>0)
    avinhrate = mean(inhrate);
end

% raster plot of last trial
figure;
subplot(2,1,1);
plot_spike(spikes, dt);
title('raster plot of the last trial')

subplot(2,1,2);
plot(meanact, 'r')
hold on
plot(meanavAct,'g')
hold on
plot(ones(ntrial)*(0.8*AgoalE+0.2*AgoalI), 'b');
legend('mean activations per trial', 'overall mean activation',...
      'target activation')
title('averaged spike number')
xlabel('trials')
ylabel('number of spikes')

% figure;
% x = linspace(0,tend,ndt);
% for i=1:n
%     subplot(n,1,i);
%     plot(x, vm_rec(i,:));
%     hold on;
%     xlabel('time (ms)')
%     ylabel('Vm (mV)')
%     title(['mebrane voltage of neuron ', num2str(i)])
% end

% figure;
% for i=1:n
%     subplot(n,2,2*i-1);
%     plot(x, ge_rec(i,:));
%     hold on;
%     xlabel('time (ms)')
%     ylabel('Ge')
%     title(['Ge of neuron ', num2str(i)])
%     subplot(n,2,2*i);
%     plot(x, gi_rec(i,:));
%     hold on;
%     xlabel('time (ms)')
%     ylabel('Gi')
%     title(['Gi of neuron ', num2str(i)])
% end

% figure;
% plotnet(w_active);

% w = we-wi;
% figure;
% imagesc(w);
% colorbar;
% title('weight matrix')
% 
% colors = ['b','r','g','c','m','y','w','k'];
% figure;
% for i=1:num_pattern
%     plot(meanacts(i,:),'color',colors(i));
%     hold on
%     legendInfo{i} = ['pattern ' num2str(i)];
% end
% legend(legendInfo);
% title('mean acts of each patter')
% 
% figure;
% for i=1:n
%     subplot(n,1,i)
%     plot(x,spikes(i,:))
%     set(gca,'xlim',[0 tend])
%     set(gca,'ytick',[0 1])
%     xlabel('time (ms)');
%     ylabel('number of spikes ');
%     title(['spike of neuron ', num2str(i)]);
%     hold on
% end
% save mini_network2pattern n idelay vrev_e vrev_i w tau_e tau_i...
%     vrest tauminv trefr vreset vthr inum stimampl ne ni...
%     w_active spike_rec w_rec dw_rec vm_rec meanact meanavAct...
%     AgoalE AgoalI ntrial aA aw;
network = struct;
homeostasis = struct;
simulation = struct;
synapse = struct;
stimulus = struct;
records = struct;

network.n = n; network.ne=ne; network.ni=ni;
network.w = w; network.w_active=w_active;

homeostasis.meanact=meanact; homeostasis.meanavAct=meanavAct;
homeostasis.Agoal = Agoal;
homeostasis.aA=aA; homeostasis.aw=aw;

simulation.ntrial=ntrial;
simulation.idelay = idelay;
simulation.tend=tend; simulation.dt=dt;
simulation.inum=inum;
simulation.stimampl=stimampl;
simulation.interval = interval;

synapse.vrev_e = vrev_e; synapse.vrev_i = vrev_i;
synapse.tau_e=tau_e; synapse.tau_i=tau_i;
synapse.tauminv=tauminv;
synapse.trefr=trefr;
synapse.vreset=vreset; synapse.vrest=vrest;
synapse.vthr=vthr;

records.spike_rec=spike_rec; records.w_rec=w_rec; records.dw_rec=dw_rec;
records.vm_rec=vm_rec;
records.meanacts=meanacts;
records.acts = acts;
save mini network homeostasis simulation synapse records;