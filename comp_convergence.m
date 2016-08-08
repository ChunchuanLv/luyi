network1=load('psd.mat');
network2=load('ppsd.mat');
meanacts = [network1.records.meanacts;
    network2.records.meanacts];
figure;
plot_acttrace(meanacts);
xlabel('trials', 'fontsize', 20);
ylabel('mean activation', 'fontsize', 20);
title('Convergence comparison', 'fontsize', 25);