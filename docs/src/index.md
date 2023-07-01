# Deneb.jl

**Deneb** is the brightest star in the constellation of the *Cygnus*, and together with **Vega** and **Altair** they form the *Summer Triangle* asterism.

**Deneb.jl** is a convenient Julia API for creating [Vega-Lite](https://vega.github.io/vega-lite/) visualizations, with high inspiration from Python's [Vega-Altair](https://altair-viz.github.io/).

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

See the [Gallery](@ref) for more examples.

## Why Deneb.jl?

The excellent [VegaLite.jl](https://github.com/queryverse/VegaLite.jl/tree/master) package, with Julia bindings to Vega-Lite, already exists in the Julia ecosystem. So, why create yet another package to accomplish the same thing?

VegaLite.jl allows for the creation of virtually any possible Vega-Lite specification in an elegant manner. However, its strategy for composing plots can be somewhat confusing and obscure (refer to this VegaLite.jl [issue](https://github.com/queryverse/VegaLite.jl/issues/230) for more details). In response to this, I proposed an alternative composition strategy in [this PR](https://github.com/queryverse/VegaLite.jl/pull/411). This, along with an excuse to start a personal project to further explore the Julia language, served as the main motivation to start creating Deneb.jl.


**Deneb.jl is not intended as a replacement for VegaLite.jl**. VegaLite.jl benefits from the attention of numerous contributors with vast experience in creating and maintaining Julia packages. In contrast, I am simply a Julia and Vega-Lite enthusiast with limited time to explore Julia's capabilities in my free time. However, if Deneb.jl attracts some interest, I'm willing to continue improving its documentation and other aspects of the package. Of course, contributions from others are always welcome.

Below a list of good and not-so-good things about Deneb.jl:
- It provides a coherent API that allows for a convenient and intuitive construction of any Vega-Lite visualization.
- Layering and composing single and multi-view charts is intuitive using the operators `+` (familiar to [Altair](https://altair-viz.github.io/) users) and `*` (familiar to [AlgebraOfGraphics.jl](https://github.com/MakieOrg/AlgebraOfGraphics.jl) users).
- While the documentation is still mostly lacking, there is a comprehensive set of examples available in the [Gallery](@ref) section. These examples should serve as a valuable resource to enable any user already familiar with Vega-Lite and/or Altair.
- I initially started this project as an exercise to learn more about Julia. Therefore, the internal design of Deneb.jl was primarily driven by my personal learning apetite at the time and might not represent the optimal or most idiomatic design choices. However, things just work.
- There are numerous tests in place, although the test coverage is not yet close to 100% in any way.
