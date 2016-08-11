network1=load('psd2.mat');
network2=load('ppsd2.mat');
n = network1.network.n;
ne = network1.network.ne;
meanacts = [network1.records.meanacts;
    network2.records.meanacts];
figure;
plot_acttrace(meanacts);
xlabel('trials', 'fontsize', 20);
ylabel('mean activation', 'fontsize', 20);

title('Convergence comparison', 'fontsize', 25);
w1=network1.network.w;
w2=network2.network.w;
figure;
subplot(1,2,1);
imagesc(w1(1:end,1:ne));
title('Weight plot PSD','Fontsize',25);
set(gca,'Fontsize',25);
subplot(1,2,2);
imagesc(w2(1:end,1:ne));
title('Weight plot PPSD', 'Fontsize',25);
set(gca,'Fontsize',25);

w_mix = zeros(n,n);
for i = 1:n
    for j = 1:n
        if rand()<0.5
            w_mix(i,j) = w1(i,j);
        else
            w_mix(i,j) = w2(i,j);
        end
    end
end
title('Convergence comparison', 'fontsize', 25);
