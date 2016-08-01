k=2;
p0=0.3;
var_reals = [];
var_rands = [];
for rep = 1:10 
    var_real = [];
    var_rand = [];
    for n = 100:50:500
        ne = round(0.8*n);
        pos = 2*rand([n 2], 'double')-1;
        [w_real pconn]= realnet(n, ne, p0, k, pos);
        % build a random network with same pconn
        w_rand = rand(n,n)<pconn;
        w_rand = w_rand-diag(diag(w_rand));
        w_rand(ne+1:end, ne+1:end)=0;
        G_rand = sparse(w_rand');
        G_real = sparse(w_real');
        i=1;
        d1 = zeros(n,1);
        d2 = zeros(n,1);
        for j = 1:n
            [dist, path, pred] = graphshortestpath(G_rand, i, j);
            d1(j) = dist;
            [dist, path, pred] = graphshortestpath(G_real, i, j);
            d2(j) = dist;
        end
        d1(d1==Inf|d1==0)=[];
        d2(d2==Inf|d2==0)=[];
        var_rand = [var_rand var(d1)];
        var_real = [var_real var(d2)];
    end
    var_rands = [var_rands; var_rand];
    var_reals = [var_reals; var_real];
end
a = linspace(100,500,9);
figure;
plot(a,mean(var_rands,1),'b');
hold on;
plot(a,mean(var_reals,1),'g');
legend('Model A', 'Model B');
title(['network structure comparison pconn=',num2str(pconn,'%.2f')]);
xlabel('number of neurons');
ylabel('variance of distance');