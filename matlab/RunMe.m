function result=RunMe(algorithm,iterations,seed)
%RUNME One-click synthetic UAV path planning with ABC (default) or PSO.
% RunMe('pso',500,1) selects PSO. Both methods use the same scene and bounds.
if nargin<1,algorithm='abc';end
if nargin<2,iterations=500;end
if nargin<3,seed=1;end
validateattributes(iterations,{'numeric'},{'scalar','integer','positive'});
root=fileparts(mfilename('fullpath'));previous_path=path;cleanup=onCleanup(@()path(previous_path)); %#ok<NASGU>
addpath(root);scenario=Scenario();[best,history]=OptimizePath(scenario,algorithm,iterations,seed);
xy=[linspace(0,500,scenario.dimension+2)',[0;best(:);0]];
result=struct('path',xy,'history',history,'cost',history(end),'algorithm',algorithm);
output=fullfile(root,'results');if ~isfolder(output),mkdir(output);end
writetable(array2table(xy,'VariableNames',{'x','y'}),fullfile(output,'path.csv'));
writetable(table((1:iterations)',history,'VariableNames',{'iteration','cost'}),fullfile(output,'convergence.csv'));
PlotResult(result,scenario);save(fullfile(output,'result.mat'),'result');
fprintf('%s: cost=%.10f; output=%s\n',upper(algorithm),result.cost,output);
end
