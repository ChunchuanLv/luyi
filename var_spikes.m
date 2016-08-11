function var_spikes(num_spikes)
num_spikes = size(num_spikes,1);
means = mean(num_spikes,2);
stds = std(num_spikes,0,2);

figure;
bar(means);
hold on;
errorbar(means, stds,'r.');
title('bar plot of spikes');
end