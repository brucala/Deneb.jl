# Introduction

Deneb.jl simply provides a convenient API to create Vega-Lite JSON specifications programmatically in Julia. Then, adequate `show` methods enable automatic displaying of charts when Deneb.jl is run on platforms such as Jupyter, Pluto, VSCode, or any other environments that can render rich MIME types. Furthermore, a chart can be saved in several formats using the function `save`.

## Vega-Lite Specifications

Vega-Lite specifications describe visualizations as encoding mappings from data to properties of graphical marks. These specifications are created with a concise declarative JSON syntax. For example:
```json
{
  "data": {"url": "https://vega.github.io/vega-datasets/data/seattle-weather.csv"},
  "mark": "bar",
  "encoding": {
    "x": {"timeUnit": "month", "field": "date", "type": "ordinal"},
    "y": {"aggregate": "mean", "field": "precipitation"}
  }
}
```
represents the following visualization:
```@example
using Deneb  #hide
Data(url="https://vega.github.io/vega-datasets/data/seattle-weather.csv") * Mark(:bar) * Encoding("month(date):O", "mean(precipitation)")  #hide
```

## The `vlspec` function

The first way to create any arbitrary Vega-Lite specification is using the `vlspec` function. The previous example can be directly translated to the following `vlspec` call:
```@example intro
using Deneb

vlspec(
    data=(; url="https://vega.github.io/vega-datasets/data/seattle-weather.csv"),
    mark=:bar,
    encoding=(
        x=(timeUnit=:month, field=:date, type=:ordinal),
        y=(aggregate=:mean, field=:precipitation),
    )
)
```

The main differences between the JSON spec and the `vlspec` are:
- JSON strings can be represented either as a Julia `String` (e.g. `"https://vega.github.io/vega-datasets/data/seattle-weather.csv"`) or as a Julia `Symbol` (e.g. `:bar`).
- key-value pairs are represented as a `NamedNtuple` (a `Dict` is also accepted), so `{}` is translated to `()`, `:` is translated to `=` and keys are not surrounded by quotation marks. Note that in Julia a `NamedTuple` with a single element needs to be defined either as `(; a=1)` or as `(a=1, )`.

Using Deneb.jl one can build a `vlspec` defining pieces programmatically using standard techniques.
```@example intro
url = "https://vega.github.io/vega-datasets/data/seattle-weather.csv"
data = (; url)
mark = :bar
x=(timeUnit=:month, field=:date, type=:ordinal)
y=(aggregate=:mean, field=:precipitation)
encoding = (; x, y)
vlspec(; data, mark, encoding)
```

## The Deneb.jl API

With `vlspec` one can build any arbitrary Vega-Lite spec programmatically, providing already an advantage over directly writing JSON specs. However, these direct translations are still rather verbose. Deneb.jl provides an API to create specs in a more concise and convenient way.

```@example intro
data = Data(url="https://vega.github.io/vega-datasets/data/seattle-weather.csv")
chart = data * Mark(:bar) * Encoding("month(date):O", "mean(precipitation)")
```

The following patterns have been demonstrated in the previous example:
- The sub-spec of the `data`, `mark` and `encoding` properties have been created with `Data`, `Mark` and `Encoding`, and then composed using the `*` operator.
- The `x` and `y` channels have been defined in the `Encoding` as positional arguments. Alternatively they could've been explicitly defined as keyword arguments.
- Inspired by Altair, a string shorthand syntax have been used to conveniently represent the `type`, `field`, `aggregate` and `timeUnit` properties of the encoding channels.

The convenience of Deneb.jl's API can be further illustrated in the following example of a more elaborated visualization. This visualization represents a bar chart of the average monthly precipitation in Seattle, overlaid with a rule for the overall yearly average, and allows for an interactive moving average for a dragged region using the mouse (a region can be selected and then dragged).

```@example intro
bar = Mark(:bar) * select_interval(
    :brush, encodings=[:x],
) * Encoding(
    "month(date):O",
    "mean(precipitation)",
    opacity=condition(:brush, 1, 0.7),
)

rule = Mark(:rule, color=:firebrick, size=3) * transform_filter(
    param(:brush)
) * Encoding(y="mean(precipitation)")

chart = data * (bar + rule)
```

As a comparison, this is how the raw Vega-Lite specification looks like for the example above:
```@example intro
print(chart)
```
