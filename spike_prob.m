function [sumL L]=spike_prob(spike, av_vm, dt)
    [n ndt] = size(spike);
    inds = size(av_vm,1);
    L = cell(inds,1);
    sumL = zeros(inds,1);
    pf = cell(inds,1);
    for ind = 1:inds
        L{ind} = zeros(n,1);
        pf{ind} = zeros(n,ndt);
        pf{ind} = exp(av_vm{ind});
        for i = 1:n
            sp = find(spike(i,:));
            lensp = length(sp);
            if lensp == 0
                L{ind}(i) = -sum(1-pf{ind}(i,:))*dt;
            elseif lensp > 0
                L{ind}(i) = -sum(1-pf{ind}(i,:))*dt+sum(1-pf{ind}(i,sp))*dt+sum(log(pf{ind}(i,sp)));
            end
        end
        sumL(ind) = sum(L{ind});
    end
end
