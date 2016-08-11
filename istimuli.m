function istim = istimuli(n, period, rep, tend, dt, inp, amp, op)
    % simulation parameters
    inp(inp==0) = [];
    ndt = tend/dt;
    istim = zeros(n, ndt);
    if strcmp(op, 'delta')
        for i = 1:rep
            istim(inp, period/dt*(i-1)+1) = amp;
        end
    end
    if strcmp(op, 'constant')
        istim(:,1:period/dt+1) = amp;
    end
end