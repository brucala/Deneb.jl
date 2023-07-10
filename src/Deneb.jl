module Deneb

using UUIDs
using NodeJS_18_jll
using JSON, Tables
using MultilineStrings: indent

const SymbolOrString = Union{Symbol, AbstractString}

include("types.jl")
include("api.jl")
include("params.jl")
include("transform.jl")
include("render.jl")
include("composition.jl")
include("themes.jl")

export
    # api
    spec, vlspec,
    Data, Mark, Encoding, Transform, Params, Facet, Repeat,
    field, layout, projection,
    resolve, resolve_scale, resolve_axis, resolve_legend,
    config, title, expr, param,
    # params
    interactive_scales,
    select, select_point, select_interval, select_legend, select_bind_input,
    select_range, select_dropdown, select_radio, select_checkbox,
    condition, condition_test,
    # transform
    transform_calculate, transform_filter, transform_window, transform_fold,
    transform_aggregate, transform_joinaggregate, transform_timeunit,
    transform_loess, transform_regression, transform_density, transform_lookup,
    transform_bin, transform_impute, transform_pivot,
    # composition
    layer, concat,
    # render
    save, # json, html,
    # themes
    set_theme!, print_theme

end # module
