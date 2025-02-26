function searcheytzinger(eyt::DenseVector{T}, target::R, compare::Symbol = :lte) where {T, R<:Union{Real,T}}
    if compare === :lte
        eytzinger_lte(eyt, target)
    elseif compare === :gte
        eytzinger_lte(eyt, target)
    else # :eql
        eytzinger_eql(eyt, target)
    end
end

function eytzinger_eql(eyt::DenseVector{T}, target::T) where {T<:Real}
    n = length(eyt)
    idx = 1
    index = 0
    @inbounds while idx <= n
        value = eyt[idx]
        if value < target
            index = idx          # track closest match <= target
            idx = 2 * idx + 1    # look into right subtree
        else
            idx *= 2             # look into left subtree
        end
    end
    index                        # !iszero(index) && eyt[index] == target
end

function eytzinger_lte(eyt::DenseVector{T}, target::T) where {T<:Real}
    n = length(eyt)
    idx = 1
    index = 0
    @inbounds while idx <= n
        value = eyt[idx]
        if value <= target
            index = idx          # track closest match <= target
            idx = 2 * idx + 1    # look into right subtree
        else
            idx *= 2             # look into left subtree
        end
    end
    index                        # eyt[index] <= target, closest from below
end

function eytzinger_gte(eyt::DenseVector{T}, target::T) where {T<:Real}
    n = length(eyt)
    idx = 1
    index = 0
    @inbounds while idx <= n
        value = eyt[idx]
        if value >= target
            index = idx          # track closest match >= target
            idx *= 2             # look into left subtree
        else
            idx = 2 * idx + 1    # look into right subtree
        end
    end
    index                        # eyt[index] >= target, closest from above
end
