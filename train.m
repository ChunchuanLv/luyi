function w = train(w, ntrials)
load mini_network2;
we = max(w,0);
wi = -min(w,0);
interval = 1;
c = 1;
row = 2;
period = 200;
rep = 1;
tend = period*rep;
dt = 0.1;
op = 'delta';
ndt = tend/dt;
si=0;
tmin=0;
aA      = 0.15; %update amount per trials.
aw      = 0.015;
AgoalE  = 1;
AgoalI  = 2;
idxE=zeros(n,1);
idxE(1:ne)=1;
idxI=zeros(n,1);
idxI(ne+1:n)=1;
Agoal   = idxE*AgoalE+idxI*AgoalI; % (col. vector)
for itrial=1:ntrials
    % Initialize variables at start of trial
    if mod(itrial, interval)==0
        ind = mod(c, row)+1;
        c = c+1;
    end
    istim = istimuli(n, period, rep, dt, inum(ind,:), stimampl, op);
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
    
    epi = 0;
    
    dw = aw*we.*((Agoal-avAct)*(avAct+epi)'.*1./(0.1+repmat(avAct,1,n))).*w_active;
    %     dw = aw*we.*((Agoal-avAct)*avAct');
    
    we = we+dw;
    we = max(0, we);
    
    %     w = w+dw;
    %     we = max(0, w);
    %     wi = -min(0, w);
    % note without any activity, no homeostasis...
    % wi is likely fixed, as in Buonomano JNP 2005
    
    avAct = avAct+aA*(sum(spikes')'-avAct); % vector with average activities
end
w = we-wi;
end