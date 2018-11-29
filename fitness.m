function result = fitness(path)
global radar1
global radar2
global R
nimama = size(radar1,2);
fenmu = R./log(20);
node_number = size(path,2);
counter = zeros(node_number,1);
countor = zeros(node_number,1);
d_x = 500./(node_number+1);
for i = 1:node_number
    for j = 1:nimama
        d = sqrt((radar1(j) - d_x.*i)^2 + (radar2(j) - path(i))^2);
        counter(i) = counter(i) + exp(-1.*d./fenmu(j));
    end
end
for i = 1:(node_number-1)
    countor(i) = sqrt((d_x)^2 + (path(i)-path(i+1))^2);
end
bufen1 = sum(countor)./500;
bufen2 = sum(counter);
result = bufen1 + bufen2;