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
