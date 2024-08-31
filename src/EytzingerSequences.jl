module EytzingerSequences

export Eytzinger,
       search_eytzinger,
       predecessors, successors

include("suport.jl")    # type-preserving versions of trailing_zeros (cttz), findfirstset (ffs)
include("type.jl")      # struct Eytzinger, low-level struct support
include("maps.jl")      # eytzinger(n) ↦ Eytzinger sequence
                        # 

const TupOrVec = Union{NTuple{N,T}, Vector{T}} where {N,T}

