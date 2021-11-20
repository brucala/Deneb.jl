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
    data(table)
"""
data(t) = DataSpec(t)

"""
    mark(type; kw...)
"""
# TODO: conflict with Base.mark
mark(type::Union{Symbol, String}; kw...) = MarkSpec(spec(type=type, kw...))

"""
    encoding(x; kw...)
    encoding(x, y)
    encoding(spec...)
"""
encoding(x::Union{Symbol, String}; kw...) = EncodingSpec(spec(x=(field=x, kw...)))
encoding(x::Union{Symbol, String}, y::Union{Symbol, String}) = EncodingSpec(spec(x=(field=x,), y=(field=y,)))
encoding(; spec...) = EncodingSpec(spec(spec))
