n = 100;
for i = 1:10
    filename = ['t-psd-p', num2str(i),'-0.2-',num2str(n),'.mat'];
    simulate(n, i, filename);
end