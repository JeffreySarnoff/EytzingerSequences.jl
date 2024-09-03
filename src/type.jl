struct Eytzinger{T<:AbstractVector}
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

function Base.getindex(x::Eytzinger, i)
    if iszero(i) || i > length(seq(x))
        return zero(eltype(seq(x)))
    end
    getindex(seq(x), i)
end


