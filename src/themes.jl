const _default_theme = (
    view=(continuousWidth=300, continuousHeight=300, step=25),
    mark=(;tooltip=true)
)

const _empty_theme = (;)

const _THEMES = Dict(
    :default => _default_theme,
    :empty => _empty_theme,
)

const _THEME_CONFIG = Ref(spec(config=_default_theme))

function set_theme!(themename::Union{Symbol, AbstractString})
    haskey(_THEMES, themename) || return @warn("Theme $themename doesn't exist.")
    set_theme!(_THEMES[Symbol(themename)])
    return
end

function set_theme!(theme::NamedTuple)
    _THEME_CONFIG[] = spec(config=theme)
end

show_theme() = print(_THEME_CONFIG[])
