```@contents
```
module UnitaryPruning

using Printf
using BenchmarkTools
using DataStructures
using InteractiveUtils

abstract type Pauli end

include("helpers.jl")
include("type_PauliString.jl")
include("type_BasisState.jl")
include("type_PauliBoolVec.jl")
include("type_PauliBitString.jl")
include("type_PauliMask.jl")
include("conversions.jl")
include("dfs.jl")
include("energy_dfs_iter.jl")
include("stochastic_evolution.jl")
include("sparse_pauli_dynamics.jl")

export Pauli
export BasisState 
export PauliString
export PauliBoolVec
export PauliBitString
export PauliMask
export commute
export commutator
export is_diagonal
export expectation_value_sign

export multiply
export countI
export countX
export countY
export countZ
export to_matrix

end # module
