module Planner
using Random
export Scenario, objective, optimize, save_result

Base.@kwdef struct Scenario
    dimension::Int = 30
    lower::Float64 = -50.0
    upper::Float64 = 50.0
    distance::Float64 = 500.0
end
const THREATS = [(100,0,40),(200,0,40),(300,0,40),(400,0,40),
    (150,50,40),(250,50,40),(350,50,40),(150,-50,40),(250,-50,40),
    (350,-50,40),(0,40,20),(466,40,20),(250,-300,260),
    (250,300,277),(466,-40,20),(30,-20,30)]

function objective(path, scene::Scenario)
    dx = scene.distance / (scene.dimension + 1)
    exposure = sum(exp(-hypot(dx*i-tx, path[i]-ty)*log(20)/radius)
                   for i in eachindex(path) for (tx,ty,radius) in THREATS)
    interior_length = sum(hypot(dx, path[i]-path[i-1]) for i in 2:length(path))
    return exposure + interior_length / scene.distance
end

function optimize(scene::Scenario; algorithm="abc", iterations=500, seed=1)
    algorithm in ("abc", "pso") || error("Algorithm must be abc or pso")
    iterations > 0 || error("Iterations must be positive")
    rng = MersenneTwister(seed)
    coordinate() = scene.lower + (scene.upper-scene.lower)*rand(rng)
    count = algorithm == "abc" ? 20 : 40
    positions = [coordinate() for _ in 1:count, _ in 1:scene.dimension]
    values = [objective(positions[i,:], scene) for i in 1:count]
    index = argmin(values)
    best, best_cost = copy(positions[index,:]), values[index]
    history = Float64[]
    function remember!()
        index = argmin(values)
        if values[index] < best_cost
            best, best_cost = copy(positions[index,:]), values[index]
        end
    end
    if algorithm == "abc"
        trials = zeros(Int, count)
        function visit!(i)
            other = rand(rng, 1:count-1)
            other += other >= i
            j = rand(rng, 1:scene.dimension)
            candidate = copy(positions[i,:])
            candidate[j] += (2*rand(rng)-1)*(positions[i,j]-positions[other,j])
            if !(scene.lower <= candidate[j] <= scene.upper)
                candidate[j] = coordinate()
            end
            value = objective(candidate, scene)
            if value < values[i]
                positions[i,:], values[i], trials[i] = candidate, value, 0
            else
                trials[i] += 1
            end
        end
        for _ in 1:iterations
            for i in 1:count
                visit!(i)
            end
            fitness = 1 ./ (1 .+ values)
            probability = 0.9 .* fitness ./ maximum(fitness) .+ 0.1
            i = 1; accepted = 0
            while accepted < count
                if rand(rng) < probability[i]
                    visit!(i); accepted += 1
                end
                i = mod1(i+1, count)
            end
            remember!()
            abandoned = findlast(==(maximum(trials)), trials)
            if trials[abandoned] > 0.1*iterations
                positions[abandoned,:] = [coordinate() for _ in 1:scene.dimension]
                values[abandoned] = objective(positions[abandoned,:], scene)
                trials[abandoned] = 0
                remember!()
            end
            push!(history, best_cost)
        end
    else
        velocity = [coordinate() for _ in 1:count, _ in 1:scene.dimension]
        personal, personal_cost = copy(positions), copy(values)
        for _ in 1:iterations
            for i in 1:count
                r1, r2 = rand(rng), rand(rng)
                for j in 1:scene.dimension
                    velocity[i,j] = 0.7298*velocity[i,j] + 1.4962*r1*(personal[i,j]-positions[i,j]) + 1.4962*r2*(best[j]-positions[i,j])
                    positions[i,j] += velocity[i,j]
                    if !(scene.lower <= positions[i,j] <= scene.upper)
                        positions[i,j] = coordinate()
                    end
                end
                values[i] = objective(positions[i,:], scene)
                if values[i] < personal_cost[i]
                    personal[i,:], personal_cost[i] = copy(positions[i,:]), values[i]
                end
                if personal_cost[i] < best_cost
                    best, best_cost = copy(personal[i,:]), personal_cost[i]
                end
            end
            push!(history, best_cost)
        end
    end
    return best, history
end

function save_result(output, scene, best, history)
    mkpath(output)
    open(joinpath(output,"path.csv"),"w") do io
        println(io,"x,y\n0,0")
        for i in eachindex(best)
            println(io,"$(i*scene.distance/(scene.dimension+1)),$(best[i])")
        end
        println(io,"500,0")
    end
    open(joinpath(output,"convergence.csv"),"w") do io
        println(io,"iteration,cost")
        for (i,cost) in enumerate(history)
            println(io,"$i,$cost")
        end
    end
    px(x) = 45 + 1.6*x
    py(y) = 193 - 1.6*y
    open(joinpath(output,"path.svg"),"w") do io
        println(io,"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 390"><rect width="900" height="390" fill="white"/><defs><clipPath id="plot"><rect x="45" y="65" width="800" height="256"/></clipPath></defs><text x="45" y="30" font-family="sans-serif" font-size="21">Synthetic UAV path planning</text><g clip-path="url(#plot)">""")
        for (x,y,r) in THREATS
            println(io,"""<circle cx="$(px(x))" cy="$(py(y))" r="$(1.6*r)" fill="#e8d4bd" fill-opacity="0.25" stroke="#b58d69" stroke-width="1"/>""")
        end
        points = ["$(px(0)),$(py(0))"; ["$(px(i*scene.distance/(scene.dimension+1))),$(py(best[i]))" for i in eachindex(best)]; "$(px(500)),$(py(0))"]
        println(io,"""<polyline fill="none" stroke="#075985" stroke-width="3" points="$(join(points," "))"/></g><rect x="45" y="65" width="800" height="256" fill="none" stroke="#94a3b8"/><g font-family="sans-serif" font-size="14"><text x="45" y="350">Start (0, 0)</text><text x="730" y="350">Goal (500, 0)</text><text x="45" y="375">Discrete cost: $(history[end])</text></g></svg>""")
    end
end
end
