struct Eytzinger{T<:DenseVector}
    seq::T
end

seq(x::Eytzinger) = x.seq

function Eytzinger(n::Integer)
    seq = map(typeof(n), eytzinger(n))
    Eytzinger(seq)
end

Base.length(x::Eytzinger{T}) where {T} = length(seq(x))
Base.isempty(x::Eytzinger) = isempty(seq(x))
Base.eltype(x::Eytzinger) = eltype(seq(x))

function get_index(x::Eytzinger, i)
    if iszero(i) || i > length(seq(x))
        return nothing
    end
    unsafe_getindex_nonmonotonic(seq(x), i)
end

import Base: extrema, minimum, maximum
struct Sequence{T}
    seq::DenseVector{T}
    bounds::NTuple{2,T}
end

seq(x::Sequence) = x.seq
bounds(x::Sequence) = x.bounds

Sequence(seq::DenseVector{T}) where {T} = Sequence(seq, extrema(seq))

Base.extrema(x::Sequence) = x.bounds
Base.minimum(x::Sequence) = x.bounds[1]
Base.maximum(x::Sequence) = x.bounds[2]

@inline Base.length(x::Sequence{T}) where {T} = length(seq(x))
@inline Base.isempty(x::Sequence{T}) where {T} = isempty(seq(x))
@inline Base.eltype(x::Sequence{T}) where {T} = T

function get_index(x::Sequence{T}, i::Int) where {T}
    if iszero(i) || i > length(x)
        return nothing
    end
    unsafe_getindex_nonmonotonic(seq(x), i)
end

struct MonotonicSequence{T}
    seq::DenseVector{T}
    bounds::NTuple{2,T}
end

seq(x::MonotonicSequence) = x.seq
bounds(x::MonotonicSequence) = x.bounds

MonotonicSequence(seq::DenseVector{T}) where {T} = Sequence(seq, extrema(seq))

Base.extrema(x::MonotonicSequence) = x.bounds
Base.minimum(x::MonotonicSequence) = x.bounds[1]
Base.maximum(x::MonotonicSequence) = x.bounds[2]

@inline Base.length(x::MonotonicSequence{T}) where {T} = length(seq(x))
@inline Base.isempty(x::MonotonicSequence{T}) where {T} = isempty(seq(x))
@inline Base.eltype(x::MonotonicSequence{T}) where {T} = T

function get_index(x::MonotonicSequence{T}, i::Int) where {T}
    if iszero(i) || i > length(x)
        return nothing
    end
    unsafe_getindex_monotonic(seq(x), i)
end

# linear indices, non-monotonic
unsafe_getindex_nonmonotonic(V::DenseVector{T}, i::Int) where {T} =
    Core.memoryrefget(Core.memoryrefnew(getfield(V, :ref), i, false), :not_atomic, false)

# linear indexing
unsafe_getindex_monotonic(V::DenseVector{T}, i::Int) where {T} =
    Core.memoryrefget(Core.memoryrefnew(getfield(V, :ref), i, false), :atomic, false)
