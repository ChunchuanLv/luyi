function [vm_rec, spike] = generate_spike(network, synapse, simulation, inp, si, period, reps)
    w=network.w;
    n=network.n;
    stimampl=simulation.stimampl;
    dt=simulation.dt;
    idelay = simulation.idelay;
    vrev_e=synapse.vrev_e; vrev_i=synapse.vrev_i;
    tau_e=synapse.tau_e; tau_i=synapse.tau_i;
    tauminv=synapse.tauminv;
    trefr=synapse.trefr;
    vreset=synapse.vreset; vrest=synapse.vrest;
    vthr=synapse.vthr;
    
    we = max(w,0);
    wi = -min(w,0);
    tend = period*reps;
    ndt = tend/dt;

    op = 'delta';
    tmin = 0;
    istim = istimuli(n, period, reps, tend, dt, inp, stimampl, op);

    vm = vrest*ones(n,1);
    ge = zeros(n,ndt);
    gi = zeros(n,ndt);
    
    spike = zeros(n,ndt);             % binary array of spikes vs time
    lastspiketime = -1000*ones(1,n);  % time since last spike, for refractoriness
    nsp = zeros(n,1);               % # spikes for each neuron
	rep_num = 0;
    vm_rec = zeros(n, ndt);
    for idt=1:ndt-1
        t = idt*dt;
        
        itdel = max((rep_num-1)*period/dt+1,idt-idelay);
        
        if mod(idt-1, period/dt) == 0
            vm = vrest*ones(n,1);
            vm_rec(:,idt) = vm;
            ge(:,idt) = zeros(n,1);
            gi(:,idt) = zeros(n,1);
            tmin = (idt-1)*dt;
            itdel = idt;
            rep_num = rep_num + 1;
        end
        % synaptic input currents
        ie = ge(:,itdel).*(vrev_e-vm);
        ii = gi(:,itdel).*(vrev_i-vm);
        vmnext = vm + dt*tauminv.*(vrest-vm+istim(:,idt)+ie+ii+si*randn(n,1));
        vm_rec(:,idt+1) = vmnext;
        refr = find(lastspiketime > t-trefr);
        vmnext(refr) = vreset;
        
        sp=(vmnext > vthr); % vector with spikes
        spi = find(sp); % indices
        
        if (size(spi)>0)
            spike(spi,idt+1) = 1*(t>tmin);
            vmnext(spi) = vreset;
            lastspiketime(spi) = t;
            for j=1:length(spi)*(t>tmin)
                k = spi(j);
                nsp(k) = nsp(k)+1;
            end
            ge(:,idt) = ge(:,idt)+we*sp;
            gi(:,idt) = gi(:,idt)+wi*sp;
        end
        
        ge(:,idt+1) = ge(:,idt)*(1-dt/tau_e);
        gi(:,idt+1) = gi(:,idt)*(1-dt/tau_i);
        vm=vmnext;
    end
end