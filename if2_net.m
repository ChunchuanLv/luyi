% implementation of Liu & Buonomano 2009 network with adaptation
clear all
close all

n=50;  % total # neurons
ne=round(0.8*n); % # excitatory neurons, 80% of total
ni=n-ne;

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
si      = 10; % noise


%%%%synapse parameters %%%
vrev_e 	= 0;
vrev_i 	= -60;
tau_e	= 5;
tau_i	= 5;

trefr	= 1;
wexc	= 40/ne/tau_e; % note different vrev
winh	= 200/ni/tau_i; %>0

% homeostasis parameters
AgoalE  = 2;
AgoalI  = 4;
Agoal   = idxE*AgoalE+idxI*AgoalI; % (col. vector)
aA      = 0.005; %update amount per trials.
aw      = 0.01;

% simulation parameters
tend	= 150; % trial time msec
dt		= 0.1; % smaller would be better
ndt		= round(tend/dt);

% create weight matrix index, w_{post,pre}
% TODO: randomize
w = zeros(n,n);
pconn=1;
for j=1:n
    if (j>ne)  
        w(:,j) = -winh*((rand(n,1)<pconn)+rand(n,1));
    else       
        w(:,j) = wexc*((rand(n,1)<pconn)+rand(n,1));
    end
end

w = w-diag(diag(w)); % exclude self-coupling
% create separate excit and inhib matrices
we = max(w,0);
wi = -min(w,0);

% pstim=0.2; % prob of neurons connected to stimulus
stimampl = 15;
% first 5 neurons receives constant stimulus
istim = zeros(n,1);
istim(1:5) = stimampl;

% simulate
tmin = 0; % don't measure spikes before tmin
ntmin = round(tmin/dt);

delay = 2;
idelay = round(delay/dt);

ntrial = 100;
avAct = zeros(n,1);
for itrial=1:ntrial
    
    % Initialize variables at start of trial
    vm = vrest*ones(n,1);
    ge = zeros(n,ndt);
    gi = zeros(n,ndt);
    
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
        
        vmnext = vm + dt*tauminv.*(vrest-vm+istim+ie+ii+si*randn(n,1));
        
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
    
    dw = aw*we.*((Agoal-avAct)*avAct');
    we = we+dw;
    % note without any activity, no homeostasis...
    % wi is likely fixed, as in Buonomano JNP 2005
    
    avAct = avAct+aA*(sum(spikes')'-avAct); % vector with average activities
    meanact(itrial) = mean(sum(spikes'));
    meanavAct(itrial) = mean(avAct);
    w12 = we(1,2);
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
figure
for ic=1:n
    sp = find(spikes(ic,:));
    spy = ic+0*sp;
    plot(sp,spy,'.');
    hold on
end

figure
plot(meanact, 'r')
hold on
plot(meanavAct,'g')


