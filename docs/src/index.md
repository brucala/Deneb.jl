# Deneb

**Deneb** is the brightest star in the constellation of the *Cygnus*, and together with **Vega** and **Altair** they form the *Summer Triangle* asterism. **Deneb.jl** is a convenient Julia API for creating [Vega-Lite](https://github.com/vega/vega-lite) visualizations.

## Quickstart

```julia
data = (a=string.('A':'I'), b=rand(0:100, 9))
Data(data) * Mark(:bar) * Encoding("a:n", "b:q")
```
![](examples/single-view_plots/simple_charts/assets/bar_chart.png)
