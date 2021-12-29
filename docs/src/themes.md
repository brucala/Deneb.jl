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

## Changing the theme

The method `set_theme!` changes the theme during the lenght of your Julia session. For instance, the theme `:empty` disables the toplovel `config` so Vega-Lite's defaults are used:
```@example themes
set_theme!(:empty)
print_theme()
```

The chart renders as:
```@example themes
chart
```
Note that the smaller figure size and that tooltips aren't enabled.

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

A theme can be specified by defining a top level `config` using a `NamedTuple`. For example, the follwing user defined theme is equivalent to the Vega `:dark` theme:
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
