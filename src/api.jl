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

# TODO: api for config, transforms, params ...

"""
    interactive_scales(;bindx=true, bindy=true, shift_on_y=false)

Creates a `ParamsSpec` that can be composed to other specs to create interactive pan
(mouse hold and drag) and zoom (mouse wheel) charts.
`bindx` and `bindy` specify if the `x` and `y` channels are to be bound.
If `shift_on_y` is true, then the shift key must be hold to pan and zoom in the `y` channel.
"""
function interactive_scales(; bindx=true, bindy=true, shift_on_y=false)
    name, select, bind = :interactive_scales, :interval, :scales
    bindx && bindy && !shift_on_y && return Params(;name, select, bind)

    if !bindx && !bindy
        @warn "At least one of `bindx` and `bindy` must be true for interactive scales."
    end

    params = Params()
    if bindx
        namex = Symbol(String(name) * "_x")
        select = (type=:interval, encodings=[:x])
        if bindy && shift_on_y
            zoom = "wheel![!event.shiftKey]"
            translate = "[mousedown[!event.shiftKey], mouseup] > mousemove"
            select = (;select..., zoom, translate)
            end
        params *= Params(;name=namex, select, bind)
    end
    if bindy
        namey = Symbol(String(name) * "_y")
        select = (type=:interval, encodings=[:y])
        if shift_on_y
            zoom = "wheel![event.shiftKey]"
            translate = "[mousedown[event.shiftKey], mouseup] > mousemove"
            select = (;select..., zoom, translate)
            end
        params *= Params(;name=namey, select, bind)
    end
    return params
end

"""
    select(type, name; value, bind, select_options...)
"""
function select(type::SymbolOrString, name::SymbolOrString; value=nothing, bind=nothing, select_options...)
    if isnothing(select_options)
        select = type
    else
        select = (; type, select_options...)
    end
    isnothing(value) && isnothing(bind) && return Params(; name, select)
    isnothing(value) && return Params(; name, select, bind)
    isnothing(bind) && return Params(; name, value, select)
    return Params(; name, value, select, bind)
end

"""
    select_point()
"""
select_point(name::SymbolOrString; value=nothing, bind=nothing, select_options...) = select(:point, name; value, bind, select_options...)

"""
    select_interval()
"""
select_interval(name::SymbolOrString; value=nothing, bind=nothing, select_options...) = select(:interval, name; value, bind, select_options...)

"""
    select_legend(name; encodings=:color, fields=nothing, bind_options=nothing)

Creates a `ParamSpec` named `name` that can be composed to other specs to create selectable legends bound
to the given `encoding` or `field`.
To customize the events that trigger legend interaction, set `bind_options` with a property
that maps to a Vega event stream (e.g. "dblclick").
More info about legend binding: https://vega.github.io/vega-lite/docs/bind.html#legend-binding
"""
function select_legend(
    name::SymbolOrString;
    encoding::Union{Nothing, SymbolOrString}=nothing,
    field::Union{Nothing, SymbolOrString}=nothing,
    bind_options=nothing,
)
    if isnothing(encoding) && isnothing(field)
        encoding = :color
    end
    if !isnothing(encoding) && !isnothing(field)
        @warn "Only one `encoding` or `field` must be given to select_legend. `field` will be ignored"
    end

    if !isnothing(encoding)
        select = (type=:point, encodings=[encoding])
    else
        select = (type=:point, fields=[field])
    end

    if isnothing(bind_options)
        bind=:legend
    else
        bind=(; legend=bind_options)
    end
    return Params(; name, select, bind)
end

"""
    select_bind_input(type, name; value, select, bind_options...)
"""
function select_bind_input(type::SymbolOrString, name::SymbolOrString; value=nothing, select=nothing, bind_options...)
    bind = (input=type, bind_options...)
    isnothing(value) && isnothing(select) && return Params(; name, bind)
    isnothing(value) && return Params(; name, select, bind)
    isnothing(select) && return Params(; name, value, bind)
    return Params(; name, value, select, bind)
end

"""
    select_range(type, name; value, select, bind_options...)
"""
function select_range(name::SymbolOrString; value=nothing, select=nothing, bind_options...)
    return select_bind_input(:range, name; value, select, bind_options...)
end

"""
    select_dropdown(type, name; options, value, select, bind_options...)
options is required
"""
function select_dropdown(name::SymbolOrString; options, value=nothing, select=nothing, bind_options...)
    return select_bind_input(:select, name; value, select, options, bind_options...)
end

"""
    select_radio(type, name; options, value, select, bind_options...)
options is required
"""
function select_radio(name::SymbolOrString; options, value=nothing, select=nothing, bind_options...)
    return select_bind_input(:radio, name; value, select, options, bind_options...)
end

"""
    select_checkbox(type, name; value, select, bind_options...)
"""
function select_checkbox(name::SymbolOrString; value=nothing, select=nothing, bind_options...)
    return select_bind_input(:checkbox, name; value, select, bind_options...)
end

"""
    expr()
"""
expr(expr::SymbolOrString) = (; expr)

"""
    param()
"""
param(param::SymbolOrString) = (; param)

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
