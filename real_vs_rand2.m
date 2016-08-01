k=2;
n=100;
ne = round(0.8*n);
var_reals = [];
var_rands = [];
for rep = 1:10
    var_real = [];
    var_rand = [];
    for p0 = 0.2:0.1:1.0
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
a = linspace(0.2,1.0,9);
figure;
plot(a,mean(var_rands,1),'b');
hold on;
plot(a,mean(var_reals,1),'g');
legend('Model A', 'Model B');
title(['network structure comparison n=', num2str(n)]);
xlabel('p0');
ylabel('variance of distance');