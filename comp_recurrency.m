k = 10;
n = 100;
rs = zeros(k,1);
rs2 = zeros(k,1);
for i=1:k
    filename = ['psd-p', num2str(i),'-0.2-',num2str(n),'.mat'];
    load(filename, 'network', 'simulation');
    inum = simulation.inum;
    w = network.w;
    w_active = network.w_active;
    ne = network.ne;
    r = recurrency(inum, w, w_active, ne);
    rs(i) = r;
end
for i=1:k
    filename2 = ['t-psd-p', num2str(i),'-0.2-',num2str(n),'.mat'];
    load(filename2, 'network', 'simulation');
    inum = simulation.inum;
    w = network.w;
    w_active = network.w_active;
    ne = network.ne;
    r = recurrency(inum, w, w_active, ne);
    rs2(i) = r;
end
figure;
plot(rs,'g')
hold on;
plot(rs2,'r');
xlabel('number of patterns');
ylabel('recurrency');
legend('non-topological', 'topological');
title('Recurrency');
