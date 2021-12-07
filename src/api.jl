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
Encoding(x::Union{Symbol, AbstractString}; kw...) = Encoding(; kw...) * Encoding(x=field(x))
Encoding(x::Union{Symbol, AbstractString}, y::Union{Symbol, AbstractString}; kw...) = Encoding(; kw...) * Encoding(x=field(x)) * Encoding(y=field(y))
Encoding(; s...) = EncodingSpec(spec(; s...))

"""
    field(field; kw...)
Shortcut to create an arbitrary encoding field.
"""
field(f::Symbol; kw...) = (field=f, kw...)
function field(f::AbstractString; kw...)
    fielddict = Dict{Symbol, AbstractString}()
    if occursin(":", f)
        f, type = split(f, ":")
        fielddict[:type] = _type(type)
    end
    if endswith(f, ")")
        aggregate, f = split(f, "(")
        f = strip(f, ')')
        fielddict[:aggregate] = aggregate
    end
    f == "" || (fielddict[:field] = f)
    return (; fielddict..., kw...)
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
