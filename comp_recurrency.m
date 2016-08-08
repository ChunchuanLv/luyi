k = 5;
n = 100;
rs = zeros(k,1);
rs2 = zeros(k,1);
for i=2:k
    filename = ['p', num2str(i), '-psd-r1-', num2str(n),'.mat'];
    load(filename, 'network', 'simulation');
    inum = simulation.inum;
    w = network.w;
    w_active = network.w_active;
    ne = network.ne;
    r = recurrency(inum, w, w_active, ne);
    rs(i) = r;
end
for i=1:k
    filename = ['psd-p1-pconn', num2str(i*0.1), '-', num2str(n),'.mat'];
    load(filename, 'network', 'simulation');
    inum = simulation.inum;
    w = network.w;
    w_active = network.w_active;
    ne = network.ne;
    r = recurrency(inum, w, w_active, ne);
    rs2(i) = r;
end
figure;
plot(rs)
xlabel('number of patterns');
ylabel('recurrency');
title('Recurrency');
figure;
plot(linspace(0.1,1,10),rs2)
xlabel('connection probability');
ylabel('recurrency');
title('Active connection');
