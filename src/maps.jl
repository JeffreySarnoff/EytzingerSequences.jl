
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

function search_eytzinger(𝒙𝒔::AbstractVector{T}, 𝒙::T) where {T}
    n = length(𝒙𝒔)
    k = 1
    while (k <= n)
        k = (k << 1) | (𝒙𝒔[k] < 𝒙)
    end
    k >>> typesafe_ffs(~k)
end

function search_eytzinger(𝒙𝒔::NTuple{N,T}, 𝒙::T) where {N,T}
    k = 1
    while (k <= N)
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

