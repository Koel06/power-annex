"Given a reference dictionary, applies a delta of +-20% to the active and reactive loads of a random bus.
The specific bus and delta can be specified alternatively, just make sure your delta is a positive float (0.2 = +-20%).
returns a Dict with the modified values."
function make_delta(ref::Dict, bus = rand(keys(new_ref[:bus])), delta = 0.2)
    @assert !isempty(ref) "Parameter shouldn't be empty"
    new_ref = copy(ref)

    print("Picked bus: $bus\n")

    load_id = nothing
    for load in keys(ref[:load])
        if ref[:load][load]["load_bus"] == bus
            load_id = load
        end
    end
    if isnothing(load_id)
        print("Load bus not found")
        return nothing
    end

    active = new_ref[:load][load_id]["pd"]
    reactive = new_ref[:load][load_id]["qd"]

    S = complex(active, reactive)

    r = delta*abs(S)  # Returns the radius magnitude times our desired percentage range
    theta = rand() * 2pi    # Random vector for choosing a new value within a circle around our given radius

    active = r*cos(theta)
    reactive = r*sin(theta)

    println("Bus $bus's active power changed by $active")
    println("While the reactive power changed by $reactive")
    
    new_ref[:load][load_id]["pd"] += active
    new_ref[:load][load_id]["qd"] += reactive

    return new_ref
end
