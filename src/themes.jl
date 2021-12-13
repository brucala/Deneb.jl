const DEFAULT_CONFIG = (
    view=(continuousWidth=300, continuousHeight=300, step=25),
    mark=(;tooltip=true)
)

const CONFIG_THEMES = Dict(
    :default => DEFAULT_CONFIG,
    :empty => (;),
)

const VEGA_THEMES = [
    :default,
    :dark,
    :excel,
    :fivethirtyeight,
    :ggplot2,
    :googlecharts,
    :latimes,
    :powerbi,
    :quartz,
    :urbaninstitute,
    :vox,
]

struct Theme
    config::Spec
    vegatheme::Symbol
    function Theme(config::Spec, vegatheme::Symbol)
        vegatheme in VEGA_THEMES && return new(config, vegatheme)
        @warn(
            "Vega theme $vegatheme doesn't exist. Available Vega themes are: $VEGA_THEMES"
        )
        return new(config, :default)
    end
end
Theme(config::NamedTuple, vegatheme::Symbol=:default) = Theme(spec(config), vegatheme)
function Theme(configtheme::Symbol=:default, vegatheme::Symbol=:default)
    haskey(CONFIG_THEMES, configtheme) || @warn(
        "Config theme $configtheme doesn't exist. Available config themes are: $(keys(CONFIG_THEMES))"
    )
    configspec = get(CONFIG_THEMES, configtheme, :default)
    return Theme(configspec, vegatheme)
end

const THEME = Ref(Theme())

themespec() = spec(THEME[])
spec(theme::Theme) = configspec(theme) * vegathemespec(theme)
configspec(theme::Theme) = isempty(theme.config) ? spec() : spec(config=theme.config)
vegathemespec(theme::Theme) = theme.vegatheme === :default ? spec() : spec(usermeta = (;embedOptions=(;theme=theme.vegatheme)))


"""
    set_theme!(theme::Symbol)

Sets the current theme to be used. The default Deneb's theme (`:default`) sets the following
global config:
```json
{
    "view": {"continuousWidth": 300, "continuousHeight": 300, "step": 25},
    "mark": {"tooltip": true}
}
```
The `:empty` theme uses Vega-Lite default empty configuration.

Other available themes are any of the Vega themes: `:dark`, `:excel`, `:fivethirtyeight`,
`:ggplot2`, `:googlecharts`, `:latimes`, `:powerbi`, `:quartz`, `:urbaninstitute`, `:vox`
(see https://vega.github.io/vega-themes for more info). In this case the `:default` global
config will be used.

    set_theme!(config_theme::Symbol, vega_theme::Symbol)

Sets the global config theme (`:default`, `:empty`) and the vega theme (use `vega_theme =
:default` for no vega theme).

    set_theme!(config::NamedTuple, [vega_theme::Symbol])

Sets a theme with a user-specified config.
"""
function set_theme!(themename::Union{Symbol, AbstractString})
    themename = Symbol(themename)
    themename in VEGA_THEMES && return set_theme!(:default, themename)
    haskey(CONFIG_THEMES, themename) && return set_theme!(themename, :default)
    return @warn(
        "Theme $themename doesn't exist. Available themes are: $(vcat(collect(keys(CONFIG_THEMES)), VEGA_THEMES))"
    )
end
function set_theme!(config_theme::Union{Symbol, AbstractString}, vega_theme::Union{Symbol, AbstractString})
    THEME[] = Theme(Symbol(config_theme), Symbol(vega_theme))
    return
end
function set_theme!(config::NamedTuple, vega_theme::Union{Symbol, AbstractString}=:default)
    THEME[] = Theme(config, Symbol(vega_theme))
    return
end

"""
    print_theme()

Prints the specification of the current theme.
"""
print_theme(io::IO=stdout) = print(io, themespec())
