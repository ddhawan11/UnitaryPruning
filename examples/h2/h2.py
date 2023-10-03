import openfermion
from openfermion import *
import numpy as np
import openfermionpyscf

d = 0.75
geometry = [('H', (0, 0, 0)), ('H', (0, 0, d)),]

charge = 0
multiplicity = 1
basis = "sto-3g"
hamiltonian = openfermionpyscf.generate_molecular_hamiltonian(geometry, basis, multiplicity, charge)

fermionic = openfermion.get_fermion_operator(hamiltonian)

#print(openfermion.transforms.jordan_wigner(fermionic))

def generate_SQ_Operators():
    """
    0a,0b,1a,1b,2a,2b,3a,3b,....  -> 0,1,2,3,...
    """

    print(" Form singlet SD operators")
    n_occ = 3
    n_vir = 3
    fermi_ops = []

#    assert(self.n_occ_a == self.n_occ_b)
#    n_occ = self.n_occ
#    n_vir = self.n_vir

#    for i in range(0,n_occ):
#        ia = 2*i
#        ib = 2*i+1
#        for a in range(0,n_vir):
#            aa = 2*n_occ + 2*a
#            ab = 2*n_occ + 2*a+1

#            termA =  FermionOperator(((aa,1),(ia,0)), 1/np.sqrt(2))
#            termA += FermionOperator(((ab,1),(ib,0)), 1/np.sqrt(2))

#            termA -= hermitian_conjugated(termA)

#            termA = normal_ordered(termA)

            #Normalize
#            coeffA = 0
#            for t in termA.terms:
#                coeff_t = termA.terms[t]
#                coeffA += coeff_t * coeff_t

#            if termA.many_body_order() > 0:
#                termA = termA/np.sqrt(coeffA)
#                fermi_ops.append(termA)


    for i in range(0,n_occ):
        ia = 2*i
        ib = 2*i+1

        for j in range(i,n_occ):
            ja = 2*j
            jb = 2*j+1

            for a in range(0,n_vir):
                aa = 2*n_occ + 2*a
                ab = 2*n_occ + 2*a+1

                for b in range(a,n_vir):
                    ba = 2*n_occ + 2*b
                    bb = 2*n_occ + 2*b+1

                    termA =  FermionOperator(((aa,1),(ba,1),(ia,0),(ja,0)), 2/np.sqrt(12))
                    termA += FermionOperator(((ab,1),(bb,1),(ib,0),(jb,0)), 2/np.sqrt(12))
                    termA += FermionOperator(((aa,1),(bb,1),(ia,0),(jb,0)), 1/np.sqrt(12))
                    termA += FermionOperator(((ab,1),(ba,1),(ib,0),(ja,0)), 1/np.sqrt(12))
                    termA += FermionOperator(((aa,1),(bb,1),(ib,0),(ja,0)), 1/np.sqrt(12))
                    termA += FermionOperator(((ab,1),(ba,1),(ia,0),(jb,0)), 1/np.sqrt(12))

                    termB  = FermionOperator(((aa,1),(bb,1),(ia,0),(jb,0)), 1/2)
                    termB += FermionOperator(((ab,1),(ba,1),(ib,0),(ja,0)), 1/2)
                    termB += FermionOperator(((aa,1),(bb,1),(ib,0),(ja,0)), -1/2)
                    termB += FermionOperator(((ab,1),(ba,1),(ia,0),(jb,0)), -1/2)

                    termA -= hermitian_conjugated(termA)
                    termB -= hermitian_conjugated(termB)

                    termA = normal_ordered(termA)
                    termB = normal_ordered(termB)

                    #Normalize
                    coeffA = 0
                    coeffB = 0
                    for t in termA.terms:
                        coeff_t = termA.terms[t]
                        coeffA += coeff_t * coeff_t
                    for t in termB.terms:
                        coeff_t = termB.terms[t]
                        coeffB += coeff_t * coeff_t


                    if termA.many_body_order() > 0:
                        termA = termA/np.sqrt(coeffA)
                        fermi_ops.append(termA)

                    if termB.many_body_order() > 0:
                        termB = termB/np.sqrt(coeffB)
                        fermi_ops.append(termB)

#                    print("A", termA)
#                    print("B", termB)
#    print("fermi", fermi_ops)
    n_ops = len(fermi_ops)
    print(" Number of operators: ", n_ops)
    return

generate_SQ_Operators()
