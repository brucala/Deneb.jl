# Deneb.jl

**Deneb** is the brightest star in the constellation of the *Cygnus*, and together with **Vega** and **Altair** they form the *Summer Triangle* asterism.

**Deneb.jl** is a convenient Julia API for creating [Vega-Lite](https://vega.github.io/vega-lite/) visualizations.

## Quickstart

```@example
using Deneb
cars = "https://vega.github.io/vega-datasets/data/cars.json"
Data(url=cars) * Mark(:point) * Encoding(
    "Horsepower:q",
    "Miles_per_Gallon:q",
    color=:Origin
)
```

## Why Deneb.jl?

The excellent [VegaLite.jl](https://github.com/queryverse/VegaLite.jl/tree/master) package with Julia bindings to Vega-Lite already exists in the Julia ecosystem. Why, then, yet another package to accomplish the same?

VegaLite.jl allows to virtually create any possible Vega-Lite specification in an elegant manner. However, the strategy for composing plots is slightly confusing and somewhat obscure (see this VegaLite.jl [issue](https://github.com/queryverse/VegaLite.jl/issues/230) for more details). A proposal for a composition strategy replacement was suggested by the author of Deneb.jl in [this PR](https://github.com/queryverse/VegaLite.jl/pull/411). That, together with an excuse for a personal project to learn more about the Julia language, was the main trigger to start creating Deneb.jl.

Below a list of good and not-so-good things about Deneb.jl:
- It provides a coherent API to build any Vega-Lite visualization in a convenient and intuitive way.
- Layering and composing single and multi-view charts is intuitive using the operators `+` (familiar to [Altair](https://altair-viz.github.io/) users) and `*` (familiar to [AlgebraOfGraphics.jl](https://github.com/MakieOrg/AlgebraOfGraphics.jl) users).
- Documentation is still mostly lacking. However, there is a fairly complete set of examples in the [Gallery](@ref) section. These examples should provide a great resource to enable any user already familiar with Vega-Lite and/or Altair.
- I started this project as an exercise to learn more about Julia. That means that the internal design of Deneb.jl was mainly driven by my learning desires at the moment and might not be neither the optimal nor the most Julian design choices. However, things just work.
- There are plenty of tests but coverage isn't by any means close to 100%.
