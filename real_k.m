p0=0.5;
n=100;
ne = round(0.8*n);
var_reals = [];
mean_reals = [];
for rep=1:10
    var_real = [];
    mean_real = [];
    for k = 0:0.5:4
        pos = 2*rand([n 2], 'double')-1;
        [w_real pconn]= realnet(n, ne, p0, k, pos);
        G_real = sparse(w_real');
        i=1;
        d = zeros(n,1);
        for j = 1:n
            [dist, path, pred] = graphshortestpath(G_real, i, j);
            d(j) = dist;
        end
        d(d==Inf|d==0)=[];
        var_real = [var_real var(d)];
        mean_real = [mean_real mean(d)];
    end
    var_reals = [var_reals; var_real];
    mean_reals = [mean_reals; mean_real];
end
a = linspace(0,4,9);
figure;
plot(a,mean(mean_reals,1),'b');
hold on;
plot(a,mean(var_reals,1),'g');
legend('mean of distance', 'variance of distance');
title('effect of Gaussian kernel');
xlabel('hyper-parameter k');
ylabel('path length');
