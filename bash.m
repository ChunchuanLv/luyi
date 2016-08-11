n =  50;
inum=[1;2;3;4];
[num_pattern, num_injection] = size(inum);
interval =1;
AgoalI=1;
rule=1;
structure=1;
si = 0;
lr = [0.1 0.01];
p = [0.2 1];
ntrial = 2000;
for i = 1
    filename = ['p4', '-psd-', num2str(n), '.mat'];
    simulate(n, p, inum, interval, AgoalI, rule, structure, si, lr, ntrial, filename);
end