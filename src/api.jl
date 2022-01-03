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
vlspec(s::ConstrainedSpec) = TopLevelSpec(; value(s)...)
vlspec(s::DataSpec) = TopLevelSpec(data = value(s))
vlspec(s::TransformSpec) = TopLevelSpec(transform = value(s))
vlspec(s::ParamsSpec) = TopLevelSpec(params = value(s))
vlspec(s::MarkSpec) = TopLevelSpec(mark = value(s))
vlspec(s::EncodingSpec) = TopLevelSpec(encoding = value(s))
vlspec(s::TopLevelSpec) = TopLevelSpec(s.toplevel, s.viewspec)


"""
    Data(table)
    Data(; url, kw...)
"""
Data(data) = DataSpec(data)
Data(; url::String, kw...) = DataSpec((;url, kw...))

"""
    Transform(; spec...)
"""
Transform(; s...) = TransformSpec(spec(; s...))

"""
    Facet(; row, kw...)
    Facet(; column, kw...)
    Facet(field; columns=nothing, kw...)
"""
Facet(f; columns=nothing, kw...) = _layout(FacetSpec, f; columns, kw...)
Facet(; kw...) = _layout(FacetSpec; kw...)

"""
    Repeat(; row, kw...)
    Repeat(; column, kw...)
    Repeat(field; columns=nothing, kw...)
    Repeat(Vector{String}; columns=nothing, kw...)
"""
Repeat(v::Vector; columns=nothing) = RepeatSpec(; repeat=v, columns)
Repeat(f; columns=nothing, kw...) = _layout(RepeatSpec, f; columns, kw...)
Repeat(; kw...) = _layout(RepeatSpec; kw...)

_layout(T::Type{<:Union{FacetSpec, RepeatSpec}}, f; columns=nothing, kw...) = T(; _key(T)=>(;field(f)..., kw...), columns)
function _layout(T::Type{<:Union{FacetSpec, RepeatSpec}}; kw...)
    s = NamedTuple(k=>k in (:column, :row) ? field(v) : v for (k,v) in kw)
    T(;_key(T)=>s)
end


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
Encoding(; s...) = EncodingSpec(spec(NamedTuple(k=>field(v) for (k,v) in pairs(s))))

"""
    field(field; kw...)
Shortcut to create an arbitrary encoding field.
"""
field(f) = f
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
        agg_property = aggregate in TIMEUNITS ? :timeUnit : :aggregate
        fielddict[agg_property] = aggregate
    end
    f == "" || (fielddict[:field] = f)
    return (; fielddict..., kw...)
end

"""
    layout(; align, bounds, center, spacing, columns)
Set layout properties. Needs to be composed with a LayoutSpec (Repeat, Facet, Concat).
"""
layout(; align=nothing, bounds=nothing, center=nothing, spacing=nothing, columns=nothing) = LayoutProperties(;align, bounds, center, spacing, columns)


"""
    projection(type; kw...)
Sets the projection properties.
"""
projection(type; kw...) = vlspec(; projection=(; type, kw...))

###
### Helper functions and constants
###

const TYPEMAP = Dict(
    "q" => "quantitative",
    "o" => "ordinal",
    "n" => "nominal",
    "t" => "temporal",
)
function _type(t::AbstractString)
    t = lowercase(t)
    return get(TYPEMAP, t, t)
end

# timeUnits from vega-lite version 4.17.0
const TIMEUNITS = [
    "year",
    "quarter",
    "month",
    "week",
    "day",
    "dayofyear",
    "date",
    "hours",
    "minutes",
    "seconds",
    "milliseconds",
    "yearquarter",
    "yearquartermonth",
    "yearmonth",
    "yearmonthdate",
    "yearmonthdatehours",
    "yearmonthdatehoursminutes",
    "yearmonthdatehoursminutesseconds",
    "yearweek",
    "yearweekday",
    "yearweekdayhours",
    "yearweekdayhoursminutes",
    "yearweekdayhoursminutesseconds",
    "yeardayofyear",
    "quartermonth",
    "monthdate",
    "monthdatehours",
    "monthdatehoursminutes",
    "monthdatehoursminutesseconds",
    "weekday",
    "weeksdayhours",
    "weekdayhoursminutes",
    "weekdayhoursminutesseconds",
    "dayhours",
    "dayhoursminutes",
    "dayhoursminutesseconds",
    "hoursminutes",
    "hoursminutesseconds",
    "minutesseconds",
    "secondsmilliseconds",
    "utcyear",
    "utcquarter",
    "utcmonth",
    "utcweek",
    "utcday",
    "utcdayofyear",
    "utcdate",
    "utchours",
    "utcminutes",
    "utcseconds",
    "utcmilliseconds",
    "utcyearquarter",
    "utcyearquartermonth",
    "utcyearmonth",
    "utcyearmonthdate",
    "utcyearmonthdatehours",
    "utcyearmonthdatehoursminutes",
    "utcyearmonthdatehoursminutesseconds",
    "utcyearweek",
    "utcyearweekday",
    "utcyearweekdayhours",
    "utcyearweekdayhoursminutes",
    "utcyearweekdayhoursminutesseconds",
    "utcyeardayofyear",
    "utcquartermonth",
    "utcmonthdate",
    "utcmonthdatehours",
    "utcmonthdatehoursminutes",
    "utcmonthdatehoursminutesseconds",
    "utcweekday",
    "utcweeksdayhours",
    "utcweekdayhoursminutes",
    "utcweekdayhoursminutesseconds",
    "utcdayhours",
    "utcdayhoursminutes",
    "utcdayhoursminutesseconds",
    "utchoursminutes",
    "utchoursminutesseconds",
    "utcminutesseconds",
    "utcsecondsmilliseconds",
]
