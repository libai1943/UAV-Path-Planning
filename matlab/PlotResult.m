function PlotResult(result,scenario)
%PLOTRESULT Show the computed path and its convergence history.
figure('Color','w','Name','UAV path');hold on;
[x,y]=meshgrid(linspace(0,500,501),linspace(-80,80,161));field=zeros(size(x));
for source=scenario.threats',field=field+exp(-hypot(x-source(1),y-source(2))*log(20)/source(3));end
contourf(x,y,field,30,'LineStyle','none');colorbar;colormap(parula);
angle=linspace(0,2*pi,120);
for source=scenario.threats',plot(source(1)+source(3)*cos(angle),source(2)+source(3)*sin(angle),'Color',[.6 .6 .6]);end
plot(result.path(:,1),result.path(:,2),'w.-','LineWidth',2,'MarkerSize',10);
scatter([0 500],[0 0],60,[.2 .8 .5;.1 .1 .1],'filled');axis equal;axis([-5 505 -80 80]);
xlabel('x');ylabel('y');title(sprintf('%s path | Discrete cost = %.6f',upper(result.algorithm),result.cost));
figure('Color','w','Name','Convergence');plot(result.history,'LineWidth',1.5);grid on;
xlabel('Iteration');ylabel('Best-so-far discrete cost');title('Convergence');
end
