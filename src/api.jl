"""
    spec(s)

Creates an arbitrary Vega-Lite spec.
"""
spec(s) = Spec(s)
spec(; s...) = Spec(NamedTuple(s))
spec(s::TopLevelSpec) = Spec(value(s))
spec(s::DataSpec) = spec(data = value(s))
spec(s::TransformSpec) = spec(transform = value(s))
spec(s::ParamsSpec) = spec(params = value(s))
spec(s::MarkSpec) = spec(mark = value(s))
spec(s::EncodingSpec) = spec(encoding = value(s))

"""
    vlspec(s)

Creates a Vega-Lite spec enforcing certain Vega-Lite constrains.
"""
vlspec(s::Spec) = TopLevelSpec(; value(s)...)
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
    Params(; spec...)
"""
Params(; s...) = ParamsSpec(spec(; s...))

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
Mark(type::SymbolOrString; kw...) = MarkSpec(spec(;type=type, kw...))
Mark(; s...) = MarkSpec(spec(; s...))

"""
    Encoding(x; kw...)
    Encoding(x, y)
    Encoding(; spec...)
"""
Encoding(x::SymbolOrString; kw...) = Encoding(; kw...) * Encoding(x=field(x))
Encoding(x::SymbolOrString, y::SymbolOrString; kw...) = Encoding(; kw...) * Encoding(x=field(x)) * Encoding(y=field(y))
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


"""
    condition(param::String, iftrue, iffalse)
    condition_test(test::String, iftrue, iffalse)
If iftrue/iffalse isn't a NamedTuple, then it'll be converted as a NamedTuple with name :value.
"""
condition(param::SymbolOrString, iftrue, iffalse=nothing) = (condition=(; param, _value(iftrue)...), _value(iffalse)...)
condition_test(test::SymbolOrString, iftrue, iffalse=nothing) = (condition=(; test, _value(iftrue)...), _value(iffalse)...)
_value(x::NamedTuple) = x
_value(::Nothing) = (;)
_value(x) = (; value=x)


"""
    resolve(type; channels...)
    resolve(type, channel, option)

Creates a `ResolveSpec`. The `type` indicates the resolution to be defined: `scale`, `axis`, or `legend`.

For scales, resolution can be specified for every channel. For axes, resolutions can be defined for positional channels (`x`, `y`, `xOffset`, `yOffset`).
For legends, resolutions can be defined for non-positional channels (`color`, `opacity`, `shape`, and `size`).

There are two options to resolve a scale, axis, or legend: `shared` and `independent`. Independent scales imply independent axes and legends.

The defaults are documented in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/resolve.html).

# Example
    resolve(:scale, color=:independent)
"""
function resolve(type::SymbolOrString, channel::SymbolOrString, option::SymbolOrString)
    nt = NamedTuple{(Symbol(channel),)}((option,))
    resolve(type; nt...)
end
function resolve(type; channels...)
    _validate_resolve(type; channels...)
    nt = NamedTuple{(Symbol(type),)}((channels,))
    return ResolveSpec(Spec(nt))
end

"""
    resolve_scale(; channels...)

Alias to `resolve(:scale; channels...)`
"""
resolve_scale(; channels...) = resolve(:scale; channels...)

"""
    resolve_axis(; channels...)

Alias to `resolve(:axis; channels...)`
"""
resolve_axis(; channels...) = resolve(:axis; channels...)

"""
    resolve_legend(; channels...)

Alias to `resolve(:legend; channels...)`
"""
resolve_legend(; channels...) = resolve(:legend; channels...)

function _validate_resolve(type; channels...)
    positional_channels = (:x, :y, :xOffset, :yOffset)
    non_positional_channels = (:color, :opacity, :shape, :size)
    allowed_channels = Dict(
        :scale => positional_channels ∪ non_positional_channels,
        :axis => positional_channels,
        :legend => non_positional_channels,
    )
    if Symbol(type) ∉ (:scale, :axis, :legend)
        @warn "resolve type must be `scale`, `axis`, or `legend`."
        @warn "$type resolve will probably be ignored"
    else
        for (channel, option) in channels
            if channel ∉ allowed_channels[type]
                @warn "channel for $type resolution must be $(allowed_channels[type]), `$channel` given"
                @warn "$type resolve for channel $channel will probably be ignored"
            elseif Symbol(option) ∉ (:shared, :independent)
                @warn "resolve option must be `shared` or `independent`, `$option` given"
                @warn "$type resolve for channel $channel will probably be ignored"
            end
        end
    end
end

# TODO: api for config, transforms, ...

"""
    interactive(;bindx=true, bindy=true, shift_on_y=false)
"""
function interactive(;bindx=true, bindy=true, shift_on_y=false)
    name, select, bind = :interactive, :interval, :scales
    bindx && bindy && !shift_on_y && return Params(;name, select, bind)

    params = Params()
    if bindx
        name = :interactivex
        select = (type=:interval, encodings=[:x])
        if bindy && shift_on_y
            zoom = "wheel![!event.shiftKey]"
            translate = "[mousedown[!event.shiftKey], mouseup] > mousemove"
            select = (;select..., zoom, translate)
            end
        params *= Params(;name, select, bind)
    end
    if bindy
        name = :interactivey
        select = (type=:interval, encodings=[:y])
        if shift_on_y
            zoom = "wheel![event.shiftKey]"
            translate = "[mousedown[event.shiftKey], mouseup] > mousemove"
            select = (;select..., zoom, translate)
            end
        params *= Params(;name, select, bind)
    end
    return params
end

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
