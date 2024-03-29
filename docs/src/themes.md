# Themes

```@setup themes
using Deneb
```

## Default Theme

Deneb's default theme (`:default`) consists of a toplevel `config` property that sets the default size and enables tooltips by default:

```@example themes
print_theme()
```

The rendered chart reflects this configuration:
```@example themes
chart = Data(
    url="https://vega.github.io/vega-datasets/data/stocks.csv"
) * Mark(
    :line, point=true
) * Encoding(
    "year(date):T",
    "mean(price):Q",
    color=:symbol,
)
chart
```

The choice to increase VegaLite's default size and to enable tooltips by default is an opinionated one. The next section explains how to disable Deneb's default theme and use VegaLite's instead.

## Changing the theme

The method `set_theme!` changes the theme during the length of your Julia session. For instance, the theme `:empty` disables the toplevel `config` so Vega-Lite's defaults are used:
```@example themes
set_theme!(:empty)
print_theme()
```

The chart renders as:
```@example themes
chart
```
Note the smaller figure size and that tooltips aren't enabled.

A default theme with the default figure size but no tooltips, `:default_no_tooltip:`, is also available:
```@example themes
set_theme!(:default_no_tooltip)
print_theme()
```
```@example themes
chart
```

## Vega themes

Other available themes are [Vega Themes](https://vega.github.io/vega-themes).
For example, the `:quartz` theme:
```@example themes
set_theme!(:quartz)
chart
```

And the `:fivethirtyeight` theme:
```@example themes
set_theme!(:fivethirtyeight)
chart
```

## User defined themes

A custom theme can be specified by defining a top level `config` using a `NamedTuple`. For example, the following user defined theme is equivalent to the Vega `:dark` theme:
```@example themes
config = (
  background="#333",
  title=(color="#fff", subtitleColor="#fff"),
  style=(;Symbol("guide-label")=>(;fill="#fff"), Symbol("guide-title")=>(;fill="#fff")),
  axis=(domainColor="#fff", gridColor="#888", tickColor="#fff")
)
set_theme!(config)
chart
```
