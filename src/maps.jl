
"""
    eytzinger_order

subfunction of eytzinger(n)
- maps a 1-based unit step sequence to the corresponding Eytzinger ordering
"""
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
    eytzinger

maps a 1-based count to the corresponding Eytzinger ordering
"""
function eytzinger(n)
    in = collect(1:n)
    out = fill(0, n)
    eytzinger_order(in, out, 0, 1)
    out
end


"""
    search_eytzinger(xs::Eytzinger, x)

search for x in xs
 
```
  if x ∈ xs
      returns the 1-based index into xs where x is found
  if x > maximum(xs) [equivalent condition: x > length(xs)]
      returns 0 (a pseudoindex, no Eytzigner index corresponds to x)
  if x < minimum(xs) [equivalent condition: x < 1]
      returns the index where 1 is found
  else x ∉ xs
      returns the the next larger value that is in xs
```

> __unchecked precondition__: xs were formed using eytzinger(n)

"""
function search_eytzinger(xs::Eytzinger, x)
    n = length(xs)
    k = 1
    while (k <= n)
        k = (k << 1) | (xs[k] < x)
    end
    k >>> ffs(~k)
end
