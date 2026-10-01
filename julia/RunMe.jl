include(joinpath(@__DIR__, "Planner.jl"))
using .Planner

function main(arguments)
    algorithm = "abc"; iterations = 500; seed = 1
    output = joinpath(@__DIR__, "results")
    i = 1
    while i <= length(arguments)
        i < length(arguments) || error("Missing option value")
        key, value = arguments[i], arguments[i+1]
        if key == "--algorithm"
            algorithm = value
        elseif key == "--iterations"
            iterations = parse(Int,value)
        elseif key == "--seed"
            seed = parse(Int,value)
        elseif key == "--output"
            output = value
        else
            error("Usage: julia RunMe.jl [--algorithm abc|pso] [--iterations 500] [--seed 1] [--output DIR]")
        end
        i += 2
    end
    scene = Scenario()
    best, history = optimize(scene; algorithm, iterations, seed)
    save_result(output, scene, best, history)
    println("$(uppercase(algorithm)): cost=$(history[end]); output=$output")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
