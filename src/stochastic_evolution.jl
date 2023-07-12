using Random

"""
    stochastic_pauli_dynamics_run(generators::Vector{PauliBoolVec{N}}, angles, o::PauliBoolVec{N}) where N

TBW
"""
function randomized_pauli_dynamics_run(generators::Vector{PauliBoolVec{N}}, angles, o_in::PauliBoolVec{N}, ket) where N

    o = deepcopy(o_in)
    #
    # for a single pauli Unitary, Un = exp(-i θn Pn/2)
    # U' O U = cos(θ/2) O - i sin(θ/2) PO
    nt = length(generators)
    length(angles) == nt || throw(DimensionMismatch)

    scale = 1.0
   
    path = zeros(Int,nt)
    sin_angles = sin.(angles)
    cos_angles = cos.(angles)
    scales = sin.(angles) .+ cos.(angles) 
    bias = sin.(angles) ./ scales
    # bias = sin.(angles).^2 
    # bias = tan.(angles) 
  
    for t in reverse(1:nt)
        g = generators[t]
        commute(o,g) == false || continue

       
        branch = rand() < bias[t]

        # if branch is true, we consider sin branch, else consider cos

        if branch 
            # sin branch

            # rand() < sin_angles[t] || return 0.0, path
            # rand() < sin_angles[t] || continue 

            # println("sin: ", bias[t])
            # error("here")
            o = multiply(g,o)
            o.θ = (o.θ + 3) % 4

            path[t] = 1
            
        else
            path[t] = -1
            # rand() < cos_angles[t] || continue 
            # rand() < cos_angles[t] || return 0.0, path
        end
        scale *= scales[t]
    end

    # return expectation_value_sign(o,ket), path
    return scale * expectation_value_sign(o,ket), path

end


"""
    stochastic_pauli_dynamics_run(generators::Vector{PauliBoolVec{N}}, angles, o::PauliBoolVec{N}) where N

TBW
"""
function randomized_pauli_dynamics(generators::Vector{P}, angles, o_in::P, ket; nsamples=1000) where {N,P<:Pauli}

    o = deepcopy(o_in)
    #
    # for a single pauli Unitary, Un = exp(-i θn Pn/2)
    # U' O U = cos(θ/2) O - i sin(θ/2) PO
    nt = length(generators)
    length(angles) == nt || throw(DimensionMismatch)

    scales = sin.(angles) .+ cos.(angles) 
    bias = sin.(angles) ./ scales
        
    # @btime stochastic_pauli_dynamics_walk($generators, $o, $ket, $bias, $scales)

    expval = zeros(ComplexF64, nsamples)
    for s in 1:nsamples
        set!(o, o_in)
        expval[s] = randomized_pauli_dynamics_walk(generators, o, ket, bias, scales)
    end
    return expval
end


# function randomized_pauli_dynamics(generators::Vector{PauliBoolVec{N}}, angles, o_in::PauliBoolVec{N}, ket; nsamples=1000) where N

#     o = deepcopy(o_in)
#     #
#     # for a single pauli Unitary, Un = exp(-i θn Pn/2)
#     # U' O U = cos(θ/2) O - i sin(θ/2) PO
#     nt = length(generators)
#     length(angles) == nt || throw(DimensionMismatch)

#     scales = sin.(angles) .+ cos.(angles) 
#     bias = sin.(angles) ./ scales
        
#     # @btime stochastic_pauli_dynamics_walk($generators, $o, $ket, $bias, $scales)

#     expval = zeros(ComplexF64, nsamples)
#     for s in 1:nsamples
#         set!(o, o_in)
#         expval[s] = randomized_pauli_dynamics_walk(generators, o, ket, bias, scales)
#     end
#     return expval
# end

function randomized_pauli_dynamics_walk(generators::Vector{P}, o::P, ket, bias, scales) where P<:Pauli 

    scale = 1.0
    nt = length(generators)
    for t in reverse(1:nt)
        g = generators[t]
        commute(o,g) == false || continue

       
        branch = rand() < bias[t]

        # if branch is true, we consider sin branch, else consider cos

        if branch 
            # sin branch
            multiply!(o,g)
            o.θ = (o.θ + 1) % 4
        end
        scale *= scales[t]
    end

    return scale * expectation_value_sign(o,ket)
end


"""
    stochastic_pauli_dynamics_run(generators::Vector{PauliBoolVec{N}}, angles, o::PauliBoolVec{N}) where N

TBW
"""
function get_random_leaf(generators::Vector{PauliBoolVec{N}}, angles, o_in::PauliBoolVec{N}, ket) where N

    o = deepcopy(o_in)
    #
    # for a single pauli Unitary, Un = exp(-i θn Pn/2)
    # U' O U = cos(θ/2) O - i sin(θ/2) PO
    nt = length(generators)
    length(angles) == nt || throw(DimensionMismatch)

    scale = 1.0
    path = 1
    sin_angles = sin.(angles)
    cos_angles = cos.(angles)
  
    for t in reverse(1:nt)
        g = generators[t]
        commute(o,g) == false || continue

       

        if rand() < .5 
            # sin branch

            # rand() < sin_angles[t] || return 0.0, path
            # rand() < sin_angles[t] || continue 

            # println("sin: ", bias[t])
            # error("here")
            o = multiply(g,o)
            o.θ = (o.θ + 3) % 4

            scale *= sin_angles[t]

        else
            scale *= cos_angles[t]
        end
    end

    # return expectation_value_sign(o,ket), path
    return scale * expectation_value_sign(o,ket), path

end