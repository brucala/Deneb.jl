# [Multi-view specs](@id multiview)

With Vega-Lite, you can not only create single view and layered visualizations, but also concatenate, repeat and facet these views into [multiview displays](https://vega.github.io/vega-lite/docs/composition.html).

## [Concatenation](@id multiview-concat)

To place view's side-by-side, Deneb.jl provides the [`Base.hcat`](@ref), [`Base.vcat`](@ref) and [`concat`](@ref) methods respectively for horizontal, vertical and general (wrappable) concatenation of views. Square braces `[]` can also be conveniently used for concatenation.

```@example multiview
using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/weather.csv")
base = transform_filter("datum.location === 'Seattle'") * vlspec(height=200)
bar = Mark(:bar) * Encoding("month(date):O", "mean(precipitation):Q")
bubble = Mark(:point) * Encoding(
    x=field("temp_min:Q", bin=true),
    y=field("temp_max:Q", bin=true),
    size="count()",
)

data * base * [bar bubble]
```

```@example multiview
data * base * [bar; bubble]
```
```@example multiview
line = Mark(:line) * Encoding("month(date):T", "mean(wind):Q")
data * base * concat(bar, bubble, line, columns=2)
```

### Examples

See the [Concatenation](@ref) section of the Gallery for more examples.

### More

More about concatenation in Vega-Lite's [Concatenation](https://vega.github.io/vega-lite/docs/concat.html) documentation.

## [Repeat](@id multiview-repeat)

Often, you may concatenate similar views where the only difference is the field that is used in an encoding. The `repeat` operator is a shortcut that creates a view for each entry in an array of fields. 

In Deneb.jl, this can be achieved using [`Repeat`](@ref). 

```@example multiview
Data(data) * Mark(:line) * Repeat(
    column = ["temp_max", "precipitation", "wind"]
) * Encoding(
    x="month(date)",
    y=(field=(;repeat=:column), aggregate=:mean),
    color=:location,
) * vlspec(
    height=200, width=200
)
```

### Examples

See the [Repeat](@ref) section of the Gallery for more examples.

### More

More about concatenation in Vega-Lite's [Repeat](https://vega.github.io/vega-lite/docs/repeat.html) documentation.

## [Facet](@id multiview-facet)

Like repeated charts, faceted charts provide a more convenient API for creating multiple views of a dataset. However, unlike `repeat` where each view contains full replication of the data set, in `facet` each view contains a different subset of the data facilitating comparison across subsets.

In Deneb.jl, this can be achieved using [`Facet`](@ref).

```@example multiview
data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")
base = Mark(:bar) * Encoding(
    x=field("Horsepower:Q", bin=(;maxbins=15)),
    y="count()"
) * vlspec(
    height=200, width=200
)

data * base * Facet(column=:Origin)
```

### Faceting with encoding channels

Vega-Lite also provides the [`facet`, `row` and `column` encoding channels](https://vega.github.io/vega-lite/docs/facet.html#facet-row-and-column-encoding-channels) that serve as a convenient way of producing facet specifications. 

```@example multiview
data * base * Encoding(column=:Origin)
```

The limitation of faceting via encoding channels is that it cannot create complicated compound charts like facet views of layered charts, while this can be achieved with the more flexible `Facet`.

### Examples

See the [Facet](@ref) section of the Gallery for more examples.

### More

More about faceting in Vega-Lite's [Facet](https://vega.github.io/vega-lite/docs/facet.html) documentation.

## [Resolution](@id multiview-resolution)
