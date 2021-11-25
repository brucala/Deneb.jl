"""
    spec(s)

Creates an arbitrary Vega-Lite spec.
"""
spec(s) = Spec(s)
spec(; s...) = Spec(NamedTuple(s))

"""
    vlspec(s)

Creates a Vega-Lite spec enforcing certain Vega-Lite constrains.
"""
vlspec(s::Spec) = TopLevelSpec(; s.spec...)
vlspec(s::NamedTuple) = TopLevelSpec(; s...)
vlspec(; s...) = TopLevelSpec(; s...)


"""
    Data(table)
"""
const Data = DataSpec

"""
    Mark(type; kw...)
"""
const Mark = MarkSpec
Mark(type::Union{Symbol, String}; kw...) = Mark(spec(;type=type, kw...))

"""
    Encoding(x; kw...)
    Encoding(x, y)
    Encoding(; spec...)
"""
const Encoding = EncodingSpec
Encoding(x::Union{Symbol, String}; kw...) = Encoding(spec(;x=(field=x, kw...)))
Encoding(x::Union{Symbol, String}, y::Union{Symbol, String}) = Encoding(spec(;x=(field=x,), y=(field=y,)))
#Encoding(; s...) = Encoding(spec(;s...))
