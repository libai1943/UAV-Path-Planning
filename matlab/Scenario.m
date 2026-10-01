function scenario = Scenario()
%SCENARIO Original sixteen-source synthetic benchmark and path bounds.
scenario.dimension=30; scenario.lower=-50; scenario.upper=50; scenario.distance=500;
scenario.threats=[100 0 40;200 0 40;300 0 40;400 0 40;150 50 40;250 50 40;350 50 40; ...
    150 -50 40;250 -50 40;350 -50 40;0 40 20;466 40 20;250 -300 260;250 300 277;466 -40 20;30 -20 30];
end
