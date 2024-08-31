struct Eytzinger{T}
    seq::T
end

seq(x::Eytzinger) = x.seq

function Base.getindex(x::Eytzinger, i)
    if iszero(i) || i > length(seq(x))
        return zero(eltype(seq(x)))
    end
    getindex(seq(x), i)
end

