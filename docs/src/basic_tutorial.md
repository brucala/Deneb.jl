# Introduction to Deneb.jl

This tutorial (as much of the documentation and example gallery) is adapted from [Vega-Lite's](https://vega.github.io/vega-lite/tutorials/getting_started.html) and [Altair's](https://altair-viz.github.io/getting_started/starting.html) documentation.

The tutorial will guide through the process of writing a visualization specification in Deneb.jl. We will walk you through all main components of Deneb by adding each of them to an example specification one-by-one. This tutorial assumes that you are working an environment that can render rich MIME types (like Jupyter, Pluto, VSCode, ...) so the plots are automatically displayed.

## The Data

Deneb.jl accepts any tabular data that supports the [Tables.jl](https://github.com/JuliaData/Tables.jl) interface (e.g. [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl)). For the purpose of this tutorial we will use data with a categorical variable in in the first column `a` and a numerical variable in a second column `b`. We'll represent this data as a `NamedTuple` (but we could choose any other representation that supports Tables.jl interface):

```@example tutorial
data = (
    a = collect("CCCDDDEEE"),
    b = [2, 7, 4, 1, 2, 6, 8, 4, 7],
)
```

Deneb.jl can now consume this data with [`Data`](@ref):

```@example tutorial
using Deneb
Data(data)
```

This created a [`DataSpec`](@ref) that contains the `data` property of a Vega-Lite specification that defines the data source of a visualization. Deneb.jl also supports other types of data sources supported by Vega-Lite, besides tabular data, as described in the [Data](@ref) section.

## Encoding Data with Marks

Basic graphical elements in Vega-Lite are marks. Marks provide basic shapes whose properties (such as position, size, and color) can be used to visually encode data, either from a data field (or a variable), or a constant value.

In Deneb.jl the `mark` of a Vega-Lite specification can be created with [`Mark`](@ref). For instance we can set the `mark` property as a `point`:

```@example tutorial
Mark(:point)
```

To show a Vega-Lite visualization of the data as a point, we can compose the `DataSpec` and the [`MarkSpec`](@ref) with the [`*`](@ref) operator to build a showable [`VegaLiteSpec`](@ref):

```@example tutorial
Data(data) * Mark(:point)
```

Now, it looks like we get a point. In fact, Vega-Lite renders one point for each object in the array, but they are all overlapping since we have not specified each point’s position.

To visually separate the points, data variables can be mapped to visual properties of a mark. For example, we can encode the variable `a` of the data with `x` channel, which represents the x-position of the points. We can do that by adding an encoding object with its key `x` mapped to a channel definition that describes variable `a`. In Deneb.jl this can be achieved with [`Encoding`](@ref):

```@example tutorial
Encoding(x=(field=:a, type=:nominal))
```

Or alternatively using this convenient shortcut (borrowed from [Altair](https://altair-viz.github.io/user_guide/encodings/index.html#encoding-shorthands)) for a field and type definition:
```@example tutorial
Encoding(x="a:N")
```

We can now compose the data, mark and encoding specs to create the following visualization:
```@example tutorial
Data(data) * Mark(:point) * Encoding(x="a:N")
```

The `Encoding` object is a key-value mapping between encoding channels (such as `x`, `y`) and definitions of the mapped data fields. The channel definition describes the field’s name (`field`) and its data type (`type`). In this example, we map the values for field `a` to the encoding channel `x` (the x-location of the points) and set `a`’s data type to `nominal`, since it represents categories.

In the visualization above, Vega-Lite automatically adds an axis with labels for the different categories as well as an axis title. However, 3 points in each category are still overlapping. So far, we have only defined a visual encoding for the field `a`. We can also map the field `b` to the `y` channel.

```@example tutorial
Encoding(y="b:Q")
```

This time we set the field type to be `quantitative` (with the shorthand `":Q"`) because the values in field `b` are numeric.
```@example tutorial
Data(data) * Mark(:point) * Encoding(
    x="a:N",
    y="b:Q"
)
```

Now we can see the raw data points. Note that Vega-Lite automatically adds grid lines to the y-axis to facilitate comparison of the `b` values.

## Data Transformation: Aggregation

Vega-Lite also supports data transformation such as aggregation. For example, we can set the `aggregate` property to `average` in the `y` channel encoding:
```@example tutorial
Encoding(
    y=(field=:b, aggregate=:average, type=:nominal)
)
```

Or using the following convenient Deneb.jl shorthand syntax for aggregation:
```@example tutorial
Encoding(y="average(b):N")
```

We can then visualize the average of of all `b` values in each `a` category:
```@example tutorial
Data(data) * Mark(:point) * Encoding(
    x="a:N",
    y="average(b):Q",
)
```

Great! You computed the aggregate values for each category and visualized the resulting value as a point. Typically aggregated values for categories are visualized using bar charts. To create a bar chart, we have to change the mark type from `point` to `bar`.
```@example tutorial
Data(data) * Mark(:bar) * Encoding(
    x="a:N",
    y="average(b):Q",
)
```

Since the quantitative value is on `y`, you automatically get a vertical bar chart. If we swap the `x` and `y` channel, we get a horizontal bar chart instead.
```@example tutorial
Data(data) * Mark(:bar) * Encoding(
    y="a:N",
    x="average(b):Q",
)
```

## Customize your Visualization

Vega-Lite automatically provides default properties for the visualization. You can further customize these values by adding more properties. Deneb.jl provides an API to conveniently set Vega-Lite's properties to customize the looks of the visualization. For instance, example, we can specify the axis titles using the the `title` property in each of the encoding channels via the [`field`](@ref) method, and we can specify the color of the mark by setting the `color` property in the `Mark`:
```@example tutorial
Data(data) * Mark(:bar, color=:tomato) * Encoding(
    y=field("a:N", title=:category),
    x=field("average(b):Q", title="Mean of b"),
)
```

## Publish your Visualization

If you are running Deneb under an environment that can render rich MIME types (Jupyter, Pluto, VSCode, ...) then charts will be automatically displayed. You can inspect the raw JSON VegaLite specification by using the `print` or the [`Deneb.json`](@ref) methods:

```@example tutorial
chart = Data(data) * Mark(:bar, color=:tomato) * Encoding(
    y=field("a:N", title=:category),
    x=field("average(b):Q", title="Mean of b"),
)
print(chart)
```
Note that the `config` property of the specification was automatically generated by the default [`Deneb.jl` theme](@ref Themes).

You can publish your visualization somewhere in the web using [Vega-Embed](https://github.com/vega/vega-embed) to embed the Vega-Lite specification in a webpage. A simple example of a stand-alone HTML document can be generated for any chart using the [`Deneb.html`](@ref) method:

```@example tutorial
print(Deneb.html(chart))
```

You can also save the visualization to a file as an stand-alone HTM document using the [`save`](@ref) method:
```
save("chart.html", chart)
```

The visualization can also be saved as a JSON file or as an image by using any of the following extensions: `.json`, `.png`, `.svg`, `.pdf`.