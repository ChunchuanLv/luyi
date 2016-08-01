function d = spike_dist(sp1, sp2, dt, tc, kerneltype)
    [n, ndt] = size(sp1);
    dist = zeros(n,1);
    for i=1:n
        x = find(sp1(i,:))*dt;
        y = find(sp2(i,:))*dt;
        dist(i) = VanRossumAlt_mvrtest(x,y,tc,kerneltype);
    end
    d = norm(dist);
end 