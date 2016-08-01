function map = plot_sorted(spike, tend, dt, n, ne, color, varargin)
    if isempty(varargin{1})
        map = zeros(n,1);
        curr_ind = 1;
        curr_ind2 = ne+1;
    else
        map = varargin{1};
        curr_ind = max(map(map<ne))+1;
        curr_ind2 = max(map(map<n))+1;
    end
    for ndt = 1:tend/dt-1
        spind = find(spike(:,ndt));
        if ~isempty(spind)
            for i = 1:length(spind)
                if map(spind(i)) == 0
                    if spind(i) > ne
                        map(spind(i)) = curr_ind2;
                        curr_ind2 = curr_ind2+1;
                    else
                        map(spind(i)) = curr_ind;
                        curr_ind = curr_ind+1;
                    end
                end
                plot(ndt*dt,map(spind(i)),'.', 'color' ,color);
                hold on;
            end
        end
    end
    plot(linspace(0,tend, ndt+1),ne, 'r');
end