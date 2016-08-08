n = 100;
pconn=0.2;
num_pattern=[1 2 3 4 5];
interval =1;
AgoalI=1;
rule=1;
structure=1;
si = 0;
p = [0.2 1];
lr = [0.1 0.01];
for i = 3:5
    filename = ['p', num2str(num_pattern(i)), '-psd-', num2str(n),'.mat'];
    simulate(n, p, num_pattern(i), interval, AgoalI, rule, structure, si, lr, filename);
end