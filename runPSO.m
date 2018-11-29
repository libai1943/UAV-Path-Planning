qwe
global radar1
global radar2
global R
% radar1 = [350 105 305 105 175 245 415 480 40 470];
% baili = size(radar1,2);
% radar2 = [200 0 -150 110 110 110 0 110 100 -50];
% R = [140 70 150 30 25 25 25 90 40 30];


radar1 = [100 200 300 400 150 250 350 150 250 350 0 466 250 250 466 30];
baili = size(radar1,2);
radar2 = [0 0 0 0 50 50 50 -50 -50 -50 40 40 -300 300 -40 -20];
R = [40 40 40 40 40 40 40 40 40 40 20 20 260 277 20 30];
%------给定初始化条件----------------------------------------------
c1=1.4962;             %学习因子1
c2=1.4962;             %学习因子2
w=0.7298;              %惯性权重
runtime =1;
MaxDT=1000;            %最大迭代次数
storeer = zeros(runtime,MaxDT);
Pbest = zeros(MaxDT,1);
D=30;                  %搜索空间维数（未知数个数）
N=40;                  %初始化群体个体数目
ub=ones(1,D).*100; %/*lower bounds of the parameters. */
lb=ones(1,D).*-50;%/*upper bound of the parameters.*/
for r=1:runtime
    
%------初始化种群的个体(可以在这里限定位置和速度的范围)------------
Range = repmat((ub-lb),[N 1]);
Lower = repmat(lb, [N 1]);
Foods = rand(N,D) .* Range + Lower;
x = Foods;
Foods = rand(N,D) .* Range + Lower;
v = Foods;
%------先计算各个粒子的适应度，并初始化Pi和pg----------------------
for i=1:N
    p(i)=fitness(x(i,:));
    y(i,:)=x(i,:);
end
pg=x(1,:);             %pg为全局最优
for i=2:N
    if fitness(x(i,:))<fitness(pg)
        pg=x(i,:);
    end
end
%------进入主要循环，按照公式依次迭代，直到满足精度要求------------
for t=1:MaxDT
    for i=1:N
        v(i,:)=w*v(i,:)+c1*rand*(y(i,:)-x(i,:))+c2*rand*(pg-x(i,:));
        x(i,:)=x(i,:)+v(i,:);
        sol=x(i,:);
        %
        ind=find(sol<lb);
        libai = rand(1,D).*(ub-lb)+lb;
        sol(ind)=libai(ind);
        ind=find(sol>ub);
        libai = rand(1,D).*(ub-lb)+lb;
        sol(ind)=libai(ind);
        %
        x(i,:)=sol;
        if fitness(x(i,:))<p(i)
            p(i)=fitness(x(i,:));
            y(i,:)=x(i,:);
        end
        if p(i)<fitness(pg) 
            pg=y(i,:);
        end
    end
    Pbest(t)=fitness(pg);
    fprintf('iteration = %d ObjVal=%g\n',t,Pbest(t));
end
%------最后给出计算结果
GlobalParams(r,:) = pg;
storeer(r,:) = Pbest;
end




% figure (1)
% apso = mean(storeer);
% plot(apso)


figure (2)
hold on
plot(0,0,'k*')
plot(500,0,'ks')

for i = 1:baili
hold on
plot(radar1(i),radar2(i),'ko');
cir_plot([radar1(i),radar2(i)],R(i));
end
legend('starting point','target point','threat center')

axis equal
%axis([-100,620,-300,200])
for i = 1:(D-1)
    plot([500/(D+1)*i,500/(D+1)*(i+1)],[GlobalParams(i),GlobalParams(i+1)],'r:','LineWidth',2);
    hold on
end
plot([0,500/(D+1)*(1)],[0,GlobalParams(1)],'r:','LineWidth',2);
plot([500/(D+1)*D,500],[GlobalParams(D),0],'r:','LineWidth',2);