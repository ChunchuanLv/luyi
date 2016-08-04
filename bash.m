n = 100;
pconn=0.2;
num_pattern=2;
AgoalI=2;
rule=[1 2 3];
structure=1;
for i = 1:3
    filename = ['psd-r', num2str(rule(i)), '-p', num2str(num_pattern),'-pconn', num2str(pconn),'-',num2str(n),'.mat'];
    simulate(n, pconn, num_pattern, AgoalI, rule(i), structure, filename);
end