# Objectives

This module contains various Julia functions useful for many projects.

# Contents

read_case.jl
  : provides a function to read cases and return the reference dictionary with all the needed network model components computed by powermodels-annex. It is a common/general file.

# ref[] dictionary

The following keys are defined for the reference dictionary after reading a case.

ref[:bus_arcs][i]
  : _i_ is the ID of a bus. The _:bus_arcs_ symbol returns a vector of arc tuples that are incident to bus _i_. Every arc tuple consists of three integers: $(l, i, y)$. Item _l_ is an arc ID, _i_ is the source bus (aka from bus), and _y_ is the destination bus. In the ref[:arcs] dictionary, every arc appears in both directions, but the arcs IDs are the same. For example, ref[:arcs] contains both $(l, i, y)$ and $(l, y, i)$. When OPF is calculated, the $p$ and $q$ variables for an arc $(l, i, y)$ contains the power flow along the arc that "leaves" bus _i_. If the $p$ value is negative, it means the power flow is coming **into** bus _i_. 