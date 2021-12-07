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
vlspec(s::TopLevelSpec) = TopLevelSpec(s.toplevel, s.spec)


"""
    Data(table)
"""
Data(data) = DataSpec(data)
Data(; url::String) = DataSpec((;url))

"""
    Mark(type; kw...)
    Mark(; spec...)
"""
Mark(type::Union{Symbol, String}; kw...) = MarkSpec(spec(;type=type, kw...))
Mark(; s...) = MarkSpec(spec(; s...))

"""
    Encoding(x; kw...)
    Encoding(x, y)
    Encoding(; spec...)
"""
Encoding(x::Union{Symbol, AbstractString}; kw...) = Encoding(; kw...) * Encoding(x=_field(x))
Encoding(x::Union{Symbol, AbstractString}, y::Union{Symbol, AbstractString}; kw...) = Encoding(; kw...) * Encoding(x=_field(x)) * Encoding(y=_field(y))
Encoding(; s...) = EncodingSpec(spec(; s...))

_field(f::Symbol) = (field=f, )
function _field(f::AbstractString)
    if occursin(":", f)
        field, type = split(f, ":")
        type = _type(type)
        return (; field, type)
    end
    (field=f, )
end

TYPEMAP = Dict(
    "q" => "quantitative",
    "o" => "ordinal",
    "n" => "nominal",
    "t" => "temporal",
)
function _type(t::AbstractString)
    t = lowercase(t)
    return get(TYPEMAP, t, t)
end
