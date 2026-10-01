function cost = PathCost(path,scenario)
%PATHCOST Archived calcu.m objective: interior length and node exposure.
dx=scenario.distance/(scenario.dimension+1);x=(1:scenario.dimension)'*dx;
d=hypot(x-scenario.threats(:,1)',path(:)-scenario.threats(:,2)');
exposure=sum(exp(-d.*log(20)./scenario.threats(:,3)'),'all');
cost=sum(hypot(dx,diff(path)))/scenario.distance+exposure;
end
