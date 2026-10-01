function [best,history]=OptimizePath(scenario,algorithm,iterations,seed)
%OPTIMIZEPATH Artificial bee colony or particle swarm optimization.
rng(seed);dimension=scenario.dimension;
if strcmp(algorithm,'abc'),count=20;else,count=40;end
positions=scenario.lower+(scenario.upper-scenario.lower)*rand(count,dimension);
values=zeros(count,1);for i=1:count,values(i)=PathCost(positions(i,:),scenario);end
[best_cost,index]=min(values);best=positions(index,:);history=zeros(iterations,1);
if strcmp(algorithm,'abc')
    trials=zeros(count,1);limit=.1*iterations;
    for cycle=1:iterations
        for i=1:count,visit(i);end
        fitness=1./(1+values);probability=.9*fitness/max(fitness)+.1;
        i=1;accepted=0;
        while accepted<count
            if rand<probability(i),visit(i);accepted=accepted+1;end
            i=mod(i,count)+1;
        end
        remember();index=find(trials==max(trials),1,'last');
        if trials(index)>limit
            positions(index,:)=scenario.lower+(scenario.upper-scenario.lower)*rand(1,dimension);
            values(index)=PathCost(positions(index,:),scenario);trials(index)=0;remember();
        end
        history(cycle)=best_cost;
    end
elseif strcmp(algorithm,'pso')
    velocity=scenario.lower+(scenario.upper-scenario.lower)*rand(count,dimension);
    personal=positions;personal_cost=values;
    for cycle=1:iterations
        for i=1:count
            velocity(i,:)=.7298*velocity(i,:)+1.4962*rand*(personal(i,:)-positions(i,:))+1.4962*rand*(best-positions(i,:));
            positions(i,:)=positions(i,:)+velocity(i,:);
            outside=positions(i,:)<scenario.lower | positions(i,:)>scenario.upper;
            positions(i,outside)=scenario.lower+(scenario.upper-scenario.lower)*rand(1,sum(outside));
            values(i)=PathCost(positions(i,:),scenario);
            if values(i)<personal_cost(i),personal(i,:)=positions(i,:);personal_cost(i)=values(i);end
            if personal_cost(i)<best_cost,best=personal(i,:);best_cost=personal_cost(i);end
        end
        history(cycle)=best_cost;
    end
else
    error('Algorithm must be abc or pso.');
end
    function visit(i)
        other=randi(count-1);if other>=i,other=other+1;end
        coordinate=randi(dimension);candidate=positions(i,:);
        candidate(coordinate)=candidate(coordinate)+(2*rand-1)*(positions(i,coordinate)-positions(other,coordinate));
        if candidate(coordinate)<scenario.lower || candidate(coordinate)>scenario.upper
            candidate(coordinate)=scenario.lower+(scenario.upper-scenario.lower)*rand;
        end
        cost=PathCost(candidate,scenario);
        if cost<values(i),positions(i,:)=candidate;values(i)=cost;trials(i)=0;else,trials(i)=trials(i)+1;end
    end
    function remember()
        [value,index]=min(values);if value<best_cost,best_cost=value;best=positions(index,:);end
    end
end
