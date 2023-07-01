# Building Blocks of a Vega-Lite Visualization

The `data`, `mark` and `encoding` properties of a Vega-Lite specification are the basic building blocks of a Vega-Lite visualization. In the Deneb.jl, sub-specifications for these properties can conveniently be defined using `Data`, `Mark`, and `Encoding` and then composed using the `*` operator to build the final specification.

```@example building_blocks
using Deneb
cars = "https://vega.github.io/vega-datasets/data/cars.json"
Data(url=cars) * Mark(:point) * Encoding(
    "Horsepower:q",
    "Miles_per_Gallon:q",
    color=:Origin
)
```

# Data

Similar to Vega-Lite, in Deneb.jl a dataset can be defined in several ways:
- as tabular data,
- as a URL from which to load the data
- or as any of Vega-Lite's data generators

## Tabular data

Deneb.jl accepts any tabular data that supports the [Tables.jl](https://github.com/JuliaData/Tables.jl) interface (e.g. [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) or any of [these formats](https://github.com/JuliaData/Tables.jl/blob/main/INTEGRATIONS.md)) by simply passing the data to `Data`.

```@example building_blocks
data = (a=[1, 2], b=["potato", "tomato"])
Data(data)
```

In the example above the source data was simply a `NamedTuple`, but it could've been for instance a `DataFrame`.

```@example building_blocks
using DataFrames
Data(DataFrame(data))
```

As shown in the output, Deneb.jl is in charge to internally transform this data into an appropriate spec with a format that Vega-Lite can interpret.
## Data from a URL

Alternatively, data can be loaded from a URL using the `url` keyword argument.

```@example building_blocks
Data(url="https://vega.github.io/vega-datasets/data/cars.json")
```

Other properties can be specified to ensure that the loaded data is correctly parsed by Vega-Lite.
```@example building_blocks
Data(
   url="https://vega.github.io/vega-datasets/data/us-10m.json",
    format=(type=:topojson, feature=:states),
)
```

To learn more about the formats accepted by Vega-Lite and the properties describing a data source from URL, refer to [Vega-Lite's documention](https://vega.github.io/vega-lite/docs/data.html#url).

## Data generators

Deneb.jl also provides a simple API to define data using any of the [data generators](https://vega.github.io/vega-lite/docs/data.html#data-generators) available in Vega-Lite. The generator type (currently Vega-Lite provides a `sequence`, a `graticule` and a `sphere` generator) can be specified as a positional argument of type `String` or `Symbol`, while the properties defining the generator can be specified as keyword arguments.

```@example building_blocks
Data(:graticule, step=[15, 15]) * Mark(:geoshape) * projection(:orthographic, rotate=[0, -45, 0])
```

# Mark

The `mark` property of a Vega-Lite specification can be defined in Deneb.jl using `Mark`, where the positional argument defines the `mark` type (`point`, `bar`, `line`,...) as a `String` or a `Symbol`.

```@example building_blocks
Mark(:point)
```

And the the keyword arguments define the other optional properties of the mark.

```@example building_blocks
Mark(:errorband, extent=:ci, borders=(opacity=0.5, strokeDash=[6, 4]))
```

Refer to [Vega-Lite's documentation](https://vega.github.io/vega-lite/docs/mark.html) to learn more about the mark types and their properties.

# Encoding