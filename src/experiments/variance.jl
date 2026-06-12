using PowerModels
using Ipopt
using JuMP
using PlotlyJS
using CSV, DataFrames

include(pwd()*"/src/util-org/read_case.jl")
include(pwd()*"/src/basemodels-org/ac_opf.jl")
include(pwd()*"/src/experiments/make_delta.jl")
include(pwd()*"/src/util-org/clear_screen.jl")

# I have commented out code for getting the reactive power changes
# Since it wasn't being used, can change in future if needed.

ref = read_case("../data/case118.m")
model = solve_model_ac!(ref, init_ac())

# For some value delta, try to simulate a small change in active and reactive powers on a bus.
# Then resolve a model, and project the arc differences. 
new_ref = make_delta(ref, 8, 0.2)    # Choose bus 8 to make a change on.
@assert(!isnothing(new_ref)) # make_delta returns nothing if we give it an invalid bus
model2 = solve_model_ac!(new_ref, init_ac())

println("Original Model Status: $(model[:status])")
println("Modified Model Status: $(model2[:status])\n")

# Constructs dictionaries"pdiff" and "qdiff" that have the total change in
# active and reactive power respectively for every arc we applied a delta to.
pdiff = Dict{NTuple{3, Int64}, Float64}()
# qdiff = Dict{NTuple{3, Int64}, Float64}()

arc_index = String[]
pd = Float64[]
pd_diff = Float64[]
b_a = String[]

for k in keys(model[:p_arcs])
    pdiff[k] = abs((model[:p_arcs][k] - model2[:p_arcs][k]))
    # qdiff[k] = abs((model[:q_arcs][k] - model2[:q_arcs][k]))
end

sorted_p_diffs = sort(collect(pdiff), by=x->x[2])      # Sort differences in active powers
# sorted_q_diffs = sort(collect(qdiff), by=x->x[2])      # Same as above, but for reactive

for k in sorted_p_diffs
    sk = string(k[1])

    push!(arc_index, sk)    # the arc as a string
    push!(pd, model[:p_arcs][k[1]]) # Active power before
    push!(pd_diff, k[2])    # Absolute value of the power difference
    push!(b_a, "Before")    # Data identifier

    push!(arc_index, sk)
    push!(pd, model2[:p_arcs][k[1]])    # Active power after
    push!(pd_diff, k[2])    # Absolute value of the power difference (duplicate data I know)
    push!(b_a, "After")
end

# Makes a dataframe for our observations, with columns as specified
df = DataFrame(arc=arc_index, power=pd, power_diff=pd_diff, type=b_a)

# The three functions below generate PlotlyJS graphs using the dataframe we specified.
# df2 is specified in each one as a way of running essentially a data query. 
# For example df.power .>= 0 removes reverse arcs which would double the graph size.
function make_hist(df::DataFrame)
    df2 = df[(df.type.=="After"), :]

    PlotlyJS.plot(df2, x=df2.power_diff, kind="histogram", 
    Layout(bargap=0.1,
    title="Frequency of Observed Changes",
    xaxis_title_text="Active Power Change",
    yaxis_title_text="Number of Arcs"))
end

function make_bar(df::DataFrame)
    df2 = df[(df.type.=="After"), :]

    PlotlyJS.plot(df2, y=df2.power_diff, x=df2.arc, kind="bar",
    Layout(bargap=0.1, title="Changes by Arc (Sorted)",
    yaxis_title_text="Change",
    xaxis_title_text="Arc",
    xaxis=attr(showticklabels=false)))
end

function make_comparison(df::DataFrame)
    df2 = df[(df.power.>=0), :]

    PlotlyJS.plot(df2, x=:arc, y=:power, color=:type, kind="bar",
    Layout(title="Before and After Compared",
    yaxis_title_text="Overall Power Demand",
    xaxis_title_text="Arc",
    xaxis=attr(showticklabels=false)))
end


# Runs a continuous loop to allow someone to keep the data they generated
# While making one, two or all 3 graphs for comparison using the same model.
# (Since new data is made every trial of the script)
print("Input H to see a histogram, B to see a bar plot, C for a comparison, or Q to quit: ")
global input = readline()

while(!(input == "Q" || input == "q"))

    (input == "h" || input == "H") ? display(make_hist(df)) : (input == "b" || input == "B") ? display(make_bar(df)) : 
    (input == "c" || input == "C") ? display(make_comparison(df)) : println("Invalid Command")

    print("Remake a graph with H/B, enter Q to quit: ")
    global input = readline()
end
