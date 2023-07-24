# Composition and Layering

## Composition with `*`

In Deneb.jl, different components or sub-specifications of a Vega-Lite visualization can be defined separately and conveniently be composed using the `*` operator to build the final specification.

```@example composition_and_layering
using Deneb
cars = Data(url="https://vega.github.io/vega-datasets/data/cars.json")
mark = Mark(:point)
encoding = Encoding("Horsepower:q", "Miles_per_Gallon:q", color=:Origin)

chart = cars * mark * encoding
```

New arbitrary properties of an existing spec can be added using the `*` operator. For instance, this examples adds a toplevel `title` property, `title` properties for the `x` and `y` encoding channels, and sets the shape of the marker to a triangle.

```@example composition_and_layering
chart = chart * title("Consumption vs power") * Mark(shape=:triangle) * Encoding(
    x=(; title="Power [hp]"),
    y=(; title="Consumption [mi / gal]")
)
```

Properties defined in the right-side spec have precedence over the left-side spec, meaning that if a given property is specified in both, then the result specification will use the property from the right-side spec.
```@example composition_and_layering
chart * title("Power vs Displacement") * Encoding(
    x=field(:Displacement, title="Displacement [in³]")
)
```

## Layering with `+`

[Layered views](https://vega.github.io/vega-lite/docs/layer.html), or charts that are superimposed one on top of another, can be conveniently created in Deneb.jl using the `+` operator.

```@example composition_and_layering
stocks = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")
base = stocks * Encoding(
    "yearquarter(date):T",
    "mean(price):Q",
)

base * (Mark(:line) + Mark(:point) + Mark(:rule))
```

Alternatively, the `layer` method can also be used, with any number of specs as arguments.

```@example composition_and_layering
base * layer(Mark(:line), Mark(:point), Mark(:rule))
```
### Order

The order matters as it determines which spec is drawn first. For example, in `spec1 + spec2`, `spec1` will appear below `spec2`.

```@example composition_and_layering
movies = Data(url="https://vega.github.io/vega-datasets/data/movies.json")
heatmap = movies * Mark(:rect) * Encoding(
    x=field("IMDB Rating:Q", bin=true),
    y=field("Rotten Tomatoes Rating:Q", bin=true),
    color=field("count()", scale=(;scheme=:greenblue)),
)

points = movies * Mark(
    :circle, color=:black, size=5
) * Encoding(
    x="IMDB Rating:Q",
    y="Rotten Tomatoes Rating:Q",
)

heatmap + points
```

If we put the two layers in the opposite order, the points will be drawn first and will be obscured by the heatmap marks:
```@example composition_and_layering
points + heatmap
```

### Resolution

When you have different scales in different layers, the scale domains are unioned so that all layers can use the same scale. In the examples above, Vega-Lite automatically used common x- and y-axis. We can disable this by setting the `resolve`` property.

The default [resolutions](https://vega.github.io/vega-lite/docs/resolve.html) for layer are shared scales, axes, and legends.

In Deneb.jl, the methods `resolve_scale`, `resolve_axis`, and `resolve_legend` are available to conveniently defined the desired resolution (`shared` or `independent`) of the respective channels. In the chart below, we set the y-scales of the different layers to be independent with `resolve_scale(y=:independent)`.

```@example composition_and_layering
base = cars * Encoding("year(Year):T") * Mark(:line)

line1 = Mark(color="#5276A7") * Encoding(
    y=field("average(Horsepower):Q", axis=(;titleColor="#5276A7"))
)

line2 = Mark(color="#F18727") * Encoding(
    y=field("average(Miles_per_Gallon):Q", axis=(;titleColor="#F18727"))
)

chart = base * (line1 + line2) * resolve_scale(y=:independent)
```

### Layering multi-views

[Multi-view](@ref multiview) layout specs (facet, repeat, concat) cannot be layered, but layered specs can be faceted/repeated/concatenated.

### Examples

More example of layered visualizations can be found in the [Layered-plots](@ref) section of the Gallery.
