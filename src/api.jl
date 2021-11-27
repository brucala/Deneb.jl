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
vlspec(s::ConstrainedSpec) = TopLevelSpec(value(s))
vlspec(s::DataSpec) = TopLevelSpec(data = value(s))
vlspec(s::MarkSpec) = TopLevelSpec(mark = value(s))
vlspec(s::EncodingSpec) = TopLevelSpec(encoding = value(s))


"""
    Data(table)
"""
const Data = DataSpec

"""
    Mark(type; kw...)
    Mark(; spec...)
"""
#const Mark = MarkSpec
Mark(type::Union{Symbol, String}; kw...) = MarkSpec(spec(;type=type, kw...))
Mark(; s...) = MarkSpec(spec(; s...))

"""
    Encoding(x; kw...)
    Encoding(x, y)
    Encoding(; spec...)
"""
#const Encoding = EncodingSpec
Encoding(x::Union{Symbol, String}; kw...) = EncodingSpec(spec(;x=(field=x, kw...)))
Encoding(x::Union{Symbol, String}, y::Union{Symbol, String}) = EncodingSpec(spec(;x=(field=x,), y=(field=y,)))
Encoding(; s...) = EncodingSpec(spec(; s...))
