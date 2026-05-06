### exports functions used to read MATPOWER cases #####

using PowerModels

# reads a case and returns a symbol dictionary containing processed
# information about the networks

#=
filename = string containing the full name of the case file to read
OBS: not sure what is returned if the read fails. Empty dict?
=#
function read_case(filename)
    PowerModels.silence()  # no warning messages
    # load the data file
    data = PowerModels.parse_file(filename)

    # Add zeros to turn linear objective functions into quadratic ones
    # so that additional parameter checks are not required
    PowerModels.standardize_cost_terms!(data, order=2)

    # Adds reasonable rate_a values to branches without them
    PowerModels.calc_thermal_limits!(data)

    # use build_ref to filter out inactive components
    ref = PowerModels.build_ref(data)[:it][:pm][:nw][0]
    # note: ref contains all the relevant system parameters needed to build the OPF model
    # When we introduce constraints and variable bounds below, we use the parameters in ref.

    return ref
end
