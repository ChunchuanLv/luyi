function d = deg_sep(w_active)
G = sparse(w_active');
n = size(w_active,1);
d = zeros(n,n);
for i=1:n
    for j=1:n
        if i~=j
            [dist, path, pred] = graphshortestpath(G, i, j);
            d(j,i)=dist;
        end
    end
end
end