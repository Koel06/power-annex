using PowerModels
using Ipopt
using JuMP

include(pwd()*"/src/util-org/read_case.jl")
include(pwd()*"/src/basemodels-org/ac_opf.jl")

ref = read_case("../data/case118.m")
model = solve_model_ac!(ref, init_ac())

println("Model Status: $(model[:status])")

# Returns the key of the arc with the greatest power magnitude in our solution.
max_key = argmax(k -> abs(model[:p_arcs][k] + model[:q_arcs][k]im), keys(model[:p_arcs]))
arc_value = (model[:p_arcs][max_key] + model[:q_arcs][max_key]im)

println("The max arc is: $max_key")
print("With a power magnitude (S) of: $arc_value")
