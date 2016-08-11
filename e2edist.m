function dist = e2edist(w, ne)
    we = w(1:ne, 1:ne);
    g = 1./(we+min(we(we>0)));
    dist = zeros(ne, ne);
    G = sparse(g');
    for i = 1:ne
        for j = 1:ne
            [cost, path, pred] = graphshortestpath(G, i, j);
            dist(j,i) = cost;
        end
    end
%     imagesc(dist); colorbar;
end