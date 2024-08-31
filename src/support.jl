# count trailing zeros (type respecting)
# cttz(0x00)        == 0x08
# cttz(0b0000_1100) == 0x02
# cttz(0b1100_0011) == 0x00
"""
    cttz(x)

count the trailing zero bits 
"""
cttz(x::I) where {I<:Integer} = Base.cttz_int(x)

# findfirstset (type respecting) 
# 1-based index of the least significant 1 bit
# ffs(0b0000) == 0x00
# ffs(0b0110) == 0x02

"""
    ffs(x)

index the least signficant 1 bit in x
- ffs(0x00) == 0x00
- ffs(0x01) == 0x01, ffs(0xf0) == 0x05
"""
@inline function ffs(x::I) where {I<:Integer} 
    z = zero(I)
    x === z && return z
    one(I) + cttz(x)
end
