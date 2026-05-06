#= functions to create and process grid data as graphs =#

using Graphs, SimpleWeightedGraphs

#=
Function to create a weighted simple graph from a dictionary representing case file data.
ref: the reference dictionary; is obtained from reading the case file
RETURNS
a weighted simple graph with nodes for the buses and edges corresponding to the branches.
INFO REGARDING THE GRAPH
- curently, no information is associated with the nodes and vertices
- nodes are represented by the bus ID from the ref disctionary
=#
function create_graph(ref)
    g = SimpleWeightedGraph(length(ref[:bus]))
    #= Traverse the branches and add the edge using the magnitude of the impedance 
    =#
    for (i, brdata) in ref[:branch]
        add_edge!(g, brdata["f_bus"], brdata["t_bus"],
                  (brdata["br_r"]^2 + brdata["br_x"]^2)^0.5)
    end

    return g
end
