# Objective
This folder contains functions that define the standard OPF models as per powerflow-annex formulation. What is new compared with powerflow-annex: functions to read case files are decoupled.

# Contents

ac_opf.jl
  : contains functions to define, run, and collect results from an AC-OPF JuMP model. Uses the example given in powermodels-annex (src/form). It uses standard AC OPF formulation.
  Returns a "result" Dict with symbol keys, with the following keys:
    - :status = termination_status(model) = MOI.OPTIMAL | MOI.TIME_LIMIT, etc
    - :cost = value of the objective function
    - :time_sec = execution time of optimize!(model) in sec
