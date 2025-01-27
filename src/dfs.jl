using UnitaryPruning
using Distributed 
"""
    involutory_transformation(o::PauliString{N}, g::PauliString{N}, t) where N

Evaluate the unitary transformation of `o` by the unitary generated by `g`: 

i.e. for the case where `o` and `g` don't commute:
```math
\\bar{\\hat{o}} = e^{it\\hat{g}}\\hat{o}e^{-it\\hat{g}} = cos(2t)\\hat{o} + i\\sin(2t)[\\hat{g}, \\hat{o}]
```
"""
function involutory_transformation(o::PauliString{N}, g::PauliString{N}, t) where N

end

function compute_expectation_value_recurse(ref_state, ham_ops, ham_par, ansatz_ops, ansatz_par; thresh=1e-8, max_depth=4)
#={{{=#
    e_hf = 0.0
    e_cadapt = 0.0
    for hi in 1:length(ham_ops)
        ei = expectation_value_sign(ham_ops[hi], ref_state) * ham_par[hi] 
        e_hf += ei
    
        energy::Vector{Float64} = [0.0]
        paths::Vector{Int} = [0,0]
        recurse_dfs!(ref_state, energy, paths, ham_ops[hi], ham_par[hi], ansatz_ops, ansatz_par, thresh=thresh, max_depth=max_depth)
        e_cadapt += energy[1]
    
        #@printf("     E contribution = %12.8f: ham coeff = %12.8f: ham op: %s %% Act Branches %12.4f %%  Tot: %i\n", 
        #        energy[1], ham_par[hi], string(ham_ops[hi]), paths[1]/sum(paths)*100, sum(paths[1]))
        #@printf("     %% Contributing Branches %12.4f %%  Tot: %i\n", paths[1]/sum(paths)*100, sum(paths[1]) )
    end
    @printf(" E(HF) = %12.8f  E(cADAPT) = %12.8f\n", e_hf, e_cadapt)
    return e_cadapt  
end
#=}}}=#

function compute_expectation_value_recurse2(ref_state, ham_ops, ham_par, ansatz_ops, ansatz_par; thresh=1e-8, max_depth=4)
#={{{=#
    e_hf = 0.0
    e_cadapt = 0.0
    for hi in 1:length(ham_ops)
        ei = expectation_value_sign(ham_ops[hi], ref_state) * ham_par[hi] 
        e_hf += ei
    
        energy::Vector{Float64} = [0.0]
        paths::Vector{Int} = [0,0]
        recurse_dfs2!(ref_state, energy, paths, ham_ops[hi], ham_par[hi], ansatz_ops, ansatz_par, thresh=thresh, max_depth=max_depth)
        e_cadapt += energy[1]
    
        #@printf("     E contribution = %12.8f: ham coeff = %12.8f: ham op: %s %% Act Branches %12.4f %%  Tot: %i\n", 
        #        energy[1], ham_par[hi], string(ham_ops[hi]), paths[1]/sum(paths)*100, sum(paths[1]))
        #@printf("     %% Contributing Branches %12.4f %%  Tot: %i\n", paths[1]/sum(paths)*100, sum(paths[1]) )
    end
    @printf(" E(HF) = %12.8f  E(cADAPT) = %12.8f\n", e_hf, e_cadapt)
    return e_cadapt  
end
#=}}}=#

function recurse_dfs!(ref_state, energy::Vector{T}, paths::Vector{Int},  
                            o, h::T, 
                            ansatz_ops::Vector, ansatz_par::Vector{T}; 
                            thresh=1e-12, max_depth=3) where {T}
    #={{{=#
    ansatz_layer = 1
    depth = 0

    vcos = cos.(2 .* ansatz_par)
    vsin = sin.(2 .* ansatz_par)


    return _recurse(ref_state, energy, paths, o, h, thresh, ansatz_layer, depth, ansatz_ops, vcos, vsin, max_depth)
end
#=}}}=#

function recurse_dfs2!(ref_state, energy::Vector{T}, paths::Vector{Int},  
                            o, h::T, 
                            ansatz_ops::Vector, ansatz_par::Vector{T}; 
                            thresh=1e-12, max_depth=3) where {T}
    #={{{=#
    ansatz_layer = 1
    depth = 0

    vcos = cos.(2 .* ansatz_par)
    vsin = sin.(2 .* ansatz_par)


    return _recurse2(ref_state, energy, paths, o, h, thresh, ansatz_layer, depth, ansatz_ops, vcos, vsin, max_depth)
end
#=}}}=#


function _recurse(ref_state, energy::Vector{T}, paths::Vector{Int}, 
                  o, h, thresh::T, ansatz_layer::Int, depth::Int, ansatz_ops::Vector, 
                  vcos::Vector{T}, vsin::Vector{T}, max_depth) where {N,T}
    #={{{=#
    if ansatz_layer == length(ansatz_ops)+1
        _found_leaf(ref_state, energy, o, h, paths)
    elseif abs(h) < thresh
        _found_leaf(ref_state, energy, o, h, paths)
    #elseif depth > max_depth
    #    _found_leaf(ref_state, energy, o, h )
    else

        g = ansatz_ops[ansatz_layer]
        if commute(g,o)
            _recurse(ref_state, energy, paths, o, h, thresh, ansatz_layer+1, depth, ansatz_ops, vcos, vsin, max_depth)
        else
            phase, or = commutator(g, o)
            if 1==0
                @btime commutator($g, $o)
                error("here")
            end
            real(phase) == 0 || error("why is phase not imaginary?", phase)
            hr = real(1im*phase) * h * vsin[ansatz_layer]
            #hr = 0.5*real(1im*phase) * h * vsin[ansatz_layer]

            # left branch
            ol = o
            hl = h * vcos[ansatz_layer]

            _recurse(ref_state, energy, paths, ol, hl, thresh, ansatz_layer+1, depth, ansatz_ops, vcos, vsin, max_depth)
            _recurse(ref_state, energy, paths, or, hr, thresh, ansatz_layer+1, depth+1, ansatz_ops, vcos, vsin, max_depth)
        end

    end
end
#=}}}=#


function _recurse2(ref_state, energy::Vector{T}, paths::Vector{Int}, 
                  o, h, thresh::T, ansatz_layer::Int, depth::Int, ansatz_ops::Vector, 
                  vcos::Vector{T}, vsin::Vector{T}, max_depth) where {N,T}
    #={{{=#
    if ansatz_layer == length(ansatz_ops)+1
        _found_leaf(ref_state, energy, o, h, paths)
    #elseif abs(h) < thresh
    #    _found_leaf(ref_state, energy, o, h, paths)
    #elseif depth > max_depth
    #    _found_leaf(ref_state, energy, o, h )
    else

        g = ansatz_ops[ansatz_layer]
        if commute(g,o)
            _recurse(ref_state, energy, paths, o, h, thresh, ansatz_layer+1, depth, ansatz_ops, vcos, vsin, max_depth)
        elseif abs(h*vsin[ansatz_layer]) < thresh
            _recurse(ref_state, energy, paths, o, h, thresh, ansatz_layer+1, depth, ansatz_ops, vcos, vsin, max_depth)
        else
            phase, or = commutator(g, o)
            if 1==0
                @btime commutator($g, $o)
                error("here")
            end
            real(phase) == 0 || error("why is phase not imaginary?", phase)
            hr = real(1im*phase) * h * vsin[ansatz_layer]
            #hr = 0.5*real(1im*phase) * h * vsin[ansatz_layer]

            # left branch
            ol = o
            hl = h * vcos[ansatz_layer]

            _recurse(ref_state, energy, paths, ol, hl, thresh, ansatz_layer+1, depth, ansatz_ops, vcos, vsin, max_depth)
            _recurse(ref_state, energy, paths, or, hr, thresh, ansatz_layer+1, depth+1, ansatz_ops, vcos, vsin, max_depth)
        end

    end
end
#=}}}=#


function _found_leaf(ref_state, energy::Vector{Float64}, o, h, paths::Vector{Int})
#={{{=#
    if is_diagonal(o)
        sign = expectation_value_sign(o, ref_state) 

        #@printf(" Found energy contribution %12.8f at ansatz layer %5i and depth %5i\n", sign*h, ansatz_layer, depth)
        energy[1] += sign*h
        paths[1] += 1
    else
        paths[2] += 1
    end
end
#=}}}=#


