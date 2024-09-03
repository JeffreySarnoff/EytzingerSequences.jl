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
@inline function typesafe_ffs(x<:Integer)
    z = zero(I)
    x === z && return z
    one(I) + typesafe_trailing_zeros(x)
end

@inline function typesafe_ffs(x::UInt8)
  x === 0x00 && return x
  0x01 + Base.cttz_int(x)
end

@inline function typesafe_ffs(x::Int8)
  x === zero(Int8) && return x
  one(Int8) + Base.cttz_int(x)
end

@inline function typesafe_ffs(x::UInt16)
  x === 0x0000 && return x
  0x0001 + Base.cttz_int(x)
end

@inline function typesafe_ffs(x::Int16)
  x === zero(Int16) && return x
  one(Int16) + Base.cttz_int(x)
end

@inline function typesafe_ffs(x::UInt32)
  x === 0x0000_0000 && return x
  0x0001 + Base.cttz_int(x)
end
