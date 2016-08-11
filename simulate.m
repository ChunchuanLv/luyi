function simulate(n0, pconn0, inum0, interval0, AgoalI0, rule0, structure0, si0, lr, trial_perpattern0, filename)
    seed=1;
    rng(seed);
    decay = false;
    record = false;
    plotall = false;
    saveall = true;
    loadw = false;
    structure = structure0;

    n=n0;  % total # neurons
    ni=1;
    ne=n-ni; % # excitatory neurons
    aA      = lr(1); %update amount per trials.
    aw      = lr(2);
    p1 = pconn0(1);
    p2 = pconn0(2);
    si = si0; % noise
    interval = interval0; % rep for each pattern
    trial_perpattern = trial_perpattern0; % trials for each pattern
    inum=inum0; % patterns
    rule = rule0;

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
    AgoalI  = AgoalI0;
    Agoal   = idxE*AgoalE+idxI*AgoalI; % (col. vector)

    % simulation parameters
    tend	= 50; % trial time msec
    dt		= 0.1; % smaller would be better
    ndt		= round(tend/dt);

    % create weight matrix index, w_{post,pre}
    % TODO: randomize
    w = zeros(n,n);
    if structure == 1
        w_active = rand(n,n)<p1;
    elseif structure == 2
        p0 = p1;
        d0 = 2.5;
        [w_active pconn]= realnet(n, ne, p0, d0);
    elseif structure == 3
        w_active = zeros(n,n);
        for i=1:ne-1
            w_active(i,i+1)=1;
            w_active(i+1,i)=1;
        end
        for i=1:ne
            w_active(i,ne+1:end)=1;
            w_active(ne+1:end,i)=1;
        end
    end
    if (structure==1||structure==2)
    	w_active(:,ne+1:end)=rand(n,ni)<p2;
    end
    w_active(ne+1:end,ne+1:end)=0;
    w_active = w_active-diag(diag(w_active)); % exclude self-coupling
    w(1:ne,ne+1:end) = -winh*(w_active(1:ne,ne+1:end));
    w(:,1:ne) = wexc*(w_active(:,1:ne));

    pconn = sum(w_active(:))/(n*(n-1));
    % create separate excit and inhib matrices
    if loadw
        load w;
    end
    we = max(w,0);
    wi = -min(w,0);
    
    [num_pattern, num_injection] = size(inum);
    % pstim=0.2; % prob of neurons connected to stimulus
    stimampl = 8000;

    fprintf('number of stimulus=%d, number of neurons=%d, connectivity=%.2f, rule=%d, aA=%.3f, aw=%.3f\n',...
        num_pattern, n, pconn, rule, aA, aw);

    % simulate
    tmin = 0; % don't measure spikes before tmin
    ntmin = round(tmin/dt);

    delay = 2;
    idelay = round(delay/dt);

    avAct = zeros(n,1);
    op = 'delta';
    c = 1;

    period = tend;
    rep = 1;
    av_err = 0;
    av_dw = 0;

    disp = 100;
    ind = 2;

    ntrial = num_pattern*trial_perpattern;

    meanacts = zeros(num_pattern,trial_perpattern);
    meanact = zeros(ntrial,1);
    acts = zeros(num_pattern,n,trial_perpattern);
    act = zeros(n, ntrial);
    meanavAct = zeros(ntrial,1);
    as = zeros(n, ntrial);

    if record
        spike_rec = zeros(round(ntrial),n,ndt);
        w_rec = zeros(round(ntrial),n,n);
        dw_rec = zeros(round(ntrial),n,n);
        vm_rec = zeros(n, ndt);
        vm_rec(:,1) = vrest*ones(n,1);
    end
    for itrial=1:ntrial
        % Initialize variables at start of trial
        if mod(floor(itrial), interval)==0
            ind = mod(c, num_pattern)+1;
            c = c+1;
        end
        istim = istimuli(n, period, rep, tend, dt, inum(ind,:), stimampl, op);
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
            if idt-idelay<1
                ie = 0;
                ii = 0;
            end
            vmnext = vm + dt*tauminv.*(vrest-vm+istim(:,idt)+ie+ii+si*randn(n,1));
            if record && itrial==ntrial
                vm_rec(:,idt+1) = vmnext;
            end

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
        a = ones(n,1);
        if rule==2
            inact = avAct(1:ne)==0;
            a(inact)=max(we(:))./(sum(we(inact,:),2)./(sum(we(inact,:)~=0,2)));
        elseif rule==3
            inact = avAct(1:ne)<Agoal(1:ne);
            a(inact)=(sum(we(inact,:),2)./(sum(we(inact,:)~=0,2)))./...
                (sum(we(:,inact),1)./(sum(we(:,inact)~=0,1)))';
        end
        as(:,itrial) = a;
        dw = aw*we.*((Agoal-avAct)*(avAct)').*repmat(a,1,n);
        we = we+dw;
        we = max(0, we);

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
            fprintf('trial: %d/%d \t error=%.2f \t |dw|=%.3f \t var(we)=%.2f \t |we|=%.2f\n',...
                itrial, ntrial, av_err, av_dw,...
                var(nonzeros(we)),...
                norm(we));
            if av_err < 10e-6 && av_dw < 10e-6
                fprintf('converged\n');
                %             break;
            end
            av_err = 0;
            av_dw = 0;
        end
        if record
            spike_rec(itrial,:,:)=spikes;
            w_rec(itrial,:,:) = we;
            dw_rec(itrial,:,:) = dw;
        end
        if decay
            aA = aA*0.9997;
            aw = aw*0.9997;
        end
    end
    w = we-wi;

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

    if plotall
        %raster plot of last trial
        figure;
        subplot(2,1,1);
        plot_spike(spikes, dt);
        title('raster plot of the last trial')

        subplot(2,1,2);
        plot(meanact, 'r')
        hold on
        plot(meanavAct,'g')
        hold on
        plot(ones(ntrial)*mean(Agoal), 'b');
        legend('mean activations per trial', 'overall mean activation',...
            'target activatspsion')
        title('averaged spike number')
        xlabel('trials')
        ylabel('number of spikes')


        figure;
        imagesc(w);
        colorbar;
        title('weight matrix')
        figure;
        plot_acttrace(meanacts);
        title('mean acts of each pattern')
    end

    %save network
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

    records.meanacts=meanacts;
    records.acts = acts;
    records.as = as;
    if record
        records.spike_rec=spike_rec; records.w_rec=w_rec; records.dw_rec=dw_rec;
        records.vm_rec=vm_rec;
    end

    if saveall
        save(filename,...
            'network', 'homeostasis', 'simulation', 'synapse', 'records', '-v7.3');
    end
end