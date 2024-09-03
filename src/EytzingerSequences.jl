module EytzingerSequences

export Eytzinger, eytzinger, search_eytzinger

const TupOrVec = Union{NTuple{N,F}, DenseVector{F}} where {N,F}

struct Eytzinger{T<:TupOrVec}
    seq::T

    function Eytzinger(seq::T) where {T<:TupOrVec}
        n = length(seq)
        eyt = eytzinger(n)
        new{T}(seq[eyt])
    end
end

seq(x::Eytzinger) = x.seq


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

#=
function eytzinger(n::R) where {R<:Real}
    seq = map(typeof(n), collect(1:n))
    if n > 32
        Eytzinger(seq)
    else
        Eytzinger(Tuple(seq))
    end
end
=#

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
    @inbounds while (k <= n)
        k = (k << 1) | (𝒙𝒔[k] < 𝒙)
    end
    k >>> typesafe_ffs(~k)
end

function search_eytzinger(𝒙𝒔::NTuple{N,T}, 𝒙::T) where {N,T}
    k = 1
    @inbounds while (k <= N)
        k = (k << 1) | (𝒙𝒔[k] < 𝒙)
    end
    k >>> typesafe_ffs(~k)
    k >= N ? k-N+1 : k + 1   
end


function search_eytzinger(𝒙𝒔::DenseVector{T}, 𝒙::T) where {T}
    k = 1
    n = length(𝒙𝒔)
    @inbounds while (k <= n)
        k = (k << 1) | (𝒙𝒔[k] < 𝒙)
    end
    k >>> typesafe_ffs(~k)
    k >= n ? k-n+1 : k + 1   
end

#=
"""
    eytzinger_search(xs, x)

index of x in xs, or -1 if not found
"""
function eytzinger_search(xs::NTuple{N,T}, target::T) where {N,T}
    index = one(T)  # Start at the root

    @inbounds while index <= N
        current = xs[index]

        if current == target
            return index  # Target found, return index
        elseif current > target
            index *= 2  # Move to the left child (2 * index)
        else
            index = 2 * index + 1  # Move to the right child (2 * index + 1)
        end
    end

    return -one(T)  # Target not found
end

function eytzinger_search(arr::DenseVector{T}, target::T) where {T}
    n = T(length(arr))
    index = one(T)  # Start at the root

    @inbounds while index <= n
        current = arr[index]

        if current == target
            return index  # Target found, return index
        elseif current > target
            index *= 2  # Move to the left child (2 * index)
        else
            index = 2 * index + 1  # Move to the right child (2 * index + 1)
        end
    end

    return -one(T)  # Target not found
end

function eytzingersearch(xs::NTuple{N,T}, target::T) where {N,T}
    n = N
    index = one(T)  # Start at the root

    @inbounds while index <= n
        current = xs[index]

        if current == target
            return index  # Target found, return index
        elseif current > target
            index *= 2  # Move to the left child (2 * index)
        else
            index = 2 * index + 1  # Move to the right child (2 * index + 1)
        end
    end

    return -one(T)  # Target not found
end

function eytzingersearch(xs::NTuple{N,T}, target::T) where {N,T}
    n = N
    index = one(T)  # Start at the root

    @inbounds while index <= n
        current = xs[index]

        if current < target
            index = 2*index + 1  # Move to the right child (2 * index + 1)
        elseif current > target
            index *= 2;  # Move to the left child (2 * index)
        else
            return index  # Target found, return index
        end
    end

    return -one(T)  # Target not found
end

function eytzingersearch(xs::DenseVector{T}, target::T) where {T}
    n = T(length(xs))
    index = one(T)  # Start at the root

    @inbounds while index <= n
        current = xs[index]

        if current < target
            index = 2 * index + 1  # Move to the right child (2 * index + 1)
        elseif current > target
            index = 2 * index  # Move to the left child (2 * index)
        else
            return index  # Target found, return index
        end
    end

    return -one(T)  # Target not found
end
=#


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
@inline function typesafe_ffs(x::Integer)
    iszero(x) ? x : one(typeof(x)) + Base.cttz_int(x)
end

@inline function typesafe_ffs(x::UInt8)
    x !== 0x00 ? 0x01 + Base.cttz_int(x) : 0x00
end
  
@inline function typesafe_ffs(x::UInt16)
    x === 0x0000 ? x : 0x0001 + Base.cttz_int(x)
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
