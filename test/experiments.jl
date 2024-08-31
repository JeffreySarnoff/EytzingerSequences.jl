

#=
Array Layouts for Comparison-Based Searching p22
=#

function eytzinger_branchfree_search(xs, x)
    i = 1
    n = length(xs)
    while i < n
        i = (i << 1) + 1 + (x > xs[i]) 
    end
    j = (i + 1) >> ffs(~(i+1))
    return j==0 ? n : j-1
end

#=
binary-search-cppcon

function eytzinger_lower_bound(xs, x)
    n = length(xs)-1
    i = 0
    while (n > 1)
        half = n >> 1
        i += (xs[half-1+1] < x) * half # replaced with cmov
        n -= half
    end
    return i
end
=#

function eytzinger_lower_bound(xs, x)
    n = length(xs) + 1
    k = 1
    while (k < n) # k <= n
        half = n >> 1
        i += (xs[half-1+1] < x) * half # replaced with cmov
        n -= half
    end
    return i
end

function eytzinger_lower_bound(xs, x)
    n = length(xs) + 1
    k = 1
    while (n > 2) # k <= n
        half = n >> 1
        k += (xs[half-1] < x) * half # replaced with cmov
        n -= half
    end
    return k
end


function search_eytzinger(xs, x)
    n = length(xs)
    k = 1
    while (k <= n)
        k = (k << 1) | (xs[k] < x)    # (k << 1) | (xs[k] <  x)
    println((;n, k)); end
    k >>> ffs(~k)
end