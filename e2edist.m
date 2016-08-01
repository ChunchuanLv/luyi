function dist = e2edist(w, ne)
    w2 = w(1:ne, 1:ne);
    w2 = 1./(w2+0.000001);
    w2 = w2-diag(diag(w2));
    dist = zeros(ne, ne);
    G = sparse(w2');
    for i = 1:ne
        for j = 1:ne
            [cost, path, pred] = graphshortestpath(G, i, j);
            dist(j,i) = cost;
        end
    end
%     imagesc(dist); colorbar;
end