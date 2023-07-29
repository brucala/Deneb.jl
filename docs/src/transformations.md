# Data transformations

Vega-Lite provides several data transformations using the `transform` property. Any arbitrary data transformation [supported by Vega-Lite](https://vega.github.io/vega-lite/docs/transform.html) can be created in Deneb.jl using [`Transform`](@ref), e.g.:

```@example transform
using Deneb
Transform(
    aggregate=[(field=:Acceleration, op=:mean, as=:mean_acc)], 
    groupby=[:Cylinders],
)
```

creates a [`Deneb.TransformSpec`](@ref) that contains the subspec for the `transform` property of an `aggregate` transformation.

The method above is rather verbose, Deneb.jl provides a number of convenient `transform_*` methods that facilitate the creation of data transformation subspecs. The previous `aggregate` transformation example could more conveniently be created using the `transform_aggregate` method.
```@example transform
transform_aggregate(mean_acc="mean(Acceleration)", groupby=:Cylinders)
```

Currently Deneb.jl supports the following Vega-Lite data transformation via `transform_*` convenient methods:

| Transform | Method | Examples |
| --- | --- | --- |
| [Aggregate](https://vega.github.io/vega-lite/docs/aggregate.html) | [`transform_aggregate()`](@ref) | [Locations of airports](@ref), [Connections among U.S. Airports](@ref), [Ridgeline plot](@ref) |
| [Bin](https://vega.github.io/vega-lite/docs/bin.html) | [`transform_bin()`](@ref) | [Ridgeline plot](@ref) |
| [Calculate](https://vega.github.io/vega-lite/docs/calculate.html) | [`transform_calculate()`](@ref) | [Line chart](@ref), [Scatterplot with links](@ref), [Isotype with emoji](@ref), [Percent of total](@ref), [Earthquakes](@ref), [Encoding channels binding](@ref), [Waterfall chart](@ref), ... |
| [Density](https://vega.github.io/vega-lite/docs/density.html) | [`transform_density()`](@ref) | [Violin plot](@ref), [Stacked density estimates](@ref) |
| [Extent](https://vega.github.io/vega-lite/docs/extent.html) | Not implemented yet | |
| [Filter](https://vega.github.io/vega-lite/docs/filter.html) | [`transform_filter()`](@ref) | [Population pyramid](@ref), [Interactive average](@ref), [Interactive Input Binding (dropdown, range, checkbox, radio widgets)](@ref), [Earthquakes](@ref), [Connections among U.S. Airports](@ref), ... |
| [Flatten](https://vega.github.io/vega-lite/docs/flatten.html) | Not implemented yet | |
| [Fold](https://vega.github.io/vega-lite/docs/fold.html) | [`transform_fold()`](@ref) | [Comet chart](@ref), [Parallel coordinates](@ref), [Scatterplot with polynomial fit](@ref) |
| [Impute](https://vega.github.io/vega-lite/docs/impute.html) | [`transform_impute()`](@ref) | [Ridgeline plot](@ref) |
| [Join Aggregate](https://vega.github.io/vega-lite/docs/joinaggregate.html) | [`transform_joinaggregate()`](@ref) | [Ridgeline plot](@ref), [Percent of total](@ref) |
| [Loess](https://vega.github.io/vega-lite/docs/loess.html) | [`transform_loess()`](@ref) | [Scatterplot with loess lines](@ref) |
| [Lookup](https://vega.github.io/vega-lite/docs/lookup.html) | [`transform_lookup()`](@ref) | [Choropleth map](@ref), [Connections among U.S. Airports](@ref)|
| [Pivot](https://vega.github.io/vega-lite/docs/pivot.html) | [`transform_pivot()`](@ref) | [Comet chart](@ref) |
| [Quantile](https://vega.github.io/vega-lite/docs/quantile.html) | Not implemented yet | |
| [Regression](https://vega.github.io/vega-lite/docs/regression.html) | [`transform_regression()`](@ref) | [Scatterplot with polynomial fit](@ref) |
| [Sample](https://vega.github.io/vega-lite/docs/sample.html) | Not implemented yet | |
| [Stack](https://vega.github.io/vega-lite/docs/stack.html) | Not implemented yet | |
| [Time Unit](https://vega.github.io/vega-lite/docs/timeunit.html) | [`transform_timeunit()`](@ref) | [Ridgeline plot](@ref) |
| [Window](https://vega.github.io/vega-lite/docs/window.html) | [`transform_window()`](@ref) | [Scatterplot with rolling mean](@ref), [Waterfall chart](@ref), [Cumulative frequency distribution](@ref), [Parallel coordinates](@ref), [Isotype with emoji](@ref) |
