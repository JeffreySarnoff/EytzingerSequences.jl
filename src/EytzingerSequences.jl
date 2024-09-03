module EytzingerSequences

export Eytzinger, eytzinger, search_eytzinger

struct Eytzinger{T}
    seq::Vector{T}
end

eytzinger(x::Vector{T}) where {T} = Eytzinger(x)


seq(x::Eytzinger) = x.seq

function Eytzinger(n::Integer)
    seq = map(typeof(n), eytzinger(n))
    Eytzinger(seq)
end

Base.length(x::Eytzinger{T}) where {T} = length(seq(x))
Base.isempty(x::Eytzinger) = isempty(seq(x))
Base.eltype(x::Eytzinger) = eltype(seq(x))

function Base.getindex(x::Eytzinger{T}, i) where {T}
    if iszero(i) || i > length(seq(x))
        return zero(eltype(seq(x)))
    end
    getindex(seq(x), i)
end

"""
    search_eytzinger(𝒙𝒔::Eytzinger, 𝒙)

search for 𝒙 in 𝒙𝒔
-  𝒙 < miniumum(𝒙𝒔) ⤇ index(𝒙𝒔, minimum(𝒙𝒔))
-  𝒙 > maximum(𝒙𝒔)  ⤇ 0 {pseudoinde𝒙 captures the exceedence of 𝒙 beyond 𝒙𝒔}
-  𝒙 ∈ 𝒙𝒔           ⤇ index(𝒙𝒔, 𝒙)
-  𝒙 ∉ 𝒙𝒔           ⤇ index(𝒙𝒔, immediate successor of 𝒙 that exists within 𝒙𝒔)
 
| computation      |   | where 𝒙 such that     |   | this function obtains a 1-based inde𝒙 or else 0        |
|:-----------------|:-:|:----------------------|:-:|:-------------------------------------------------------|
| precheck         |   |  𝒙 > maximum(𝒙𝒔)      |   | 0 (a pseudoindex, no Eytzigner inde𝒙 corresponds to 𝒙) |
| precheck         |   |  𝒙 < minimum(𝒙𝒔)      |   | the inde𝒙 where minimum(𝒙𝒔) is found                   |
| function logic   |   |  𝒙 ∈ 𝒙𝒔               |   | the inde𝒙 where 𝒙 is found                             |
| simultaneously   |   |  𝒙 ∉ 𝒙𝒔               |   | the inde𝒙 of the value in 𝒙𝒔 closest to and > 𝒙        |

*Unchecked Precondition* 𝒙𝒔 were formed using eytzinger(n)

""" search_eytzinger

function search_eytzinger(𝒙𝒔::Eytzinger, 𝒙)
    n = length(𝒙𝒔)
    k = 1
    while (k <= n)
        k = (k << 1) | (𝒙𝒔[k] < 𝒙)
    end
    k >>> typesafe_ffs(~k)
end

"""
    eytzinger

maps a 1-based count to the corresponding Eytzinger ordering
""" eytzinger

function eytzinger(n)
    in = collect(1:n)
    out = fill(0, n)
    eytzinger_order(in, out, 0, 1)
    out
end

"""
    eytzinger_order

private service function provided for `eytzinger(n)`

- maps a 1-based unit step sequence to the corresponding Eytzinger ordering
""" eytzinger_order

function eytzinger_order(in, out, i=0, k=1)
    if k <= length(in)
       i = eytzinger_order(in, out, i, 2*k)
       out[k-1+1] = in[i+1]
       i += 1
       i = eytzinger_order(in, out, i, 2*k+1)
    end
    return i
end

"""
    typesafe_trailing_zeros(x::T)::T {T<:Integer}

counts the trailing zero bits, preserves type
  - typesafe_trailing_zeros(x::Integer)::typeof(x)
  - compare Base.trailing_zeros(x::Integer)::Int
"""
typesafe_trailing_zeros(x::I) where {I<:Integer} = Base.cttz_int(x)

"""
   typesafe_ffs(x::T)::T {T<:Integer}

index of the least signficant 1 bit in x, preserves type
- ako ffs [find first set]
- ffs(0x00) == 0x00, ffs(0x0000) == 0x0000
- ffs(0x01) == 0x01, ffs(0xf0) == 0x05
- ffs(0x0001) == 0x0001, ffs(0x00f0) == 0x0005
"""
@inline function typesafe_ffs(x::I) where {I<:Integer} 
    z = zero(I)
    x === z && return z
    one(I) + typesafe_trailing_zeros(x)
end

#=
export Eytzinger,
       search_eytzinger,
       predecessors, successors

include("support.jl")    # type-preserving versions of trailing_zeros (cttz), findfirstset (ffs)
include("type.jl")      # struct Eytzinger, low-level struct support
include("maps.jl")      # eytzinger(n) ↦ Eytzinger sequence
                        # 
=#

end  # EytzignerSequences
