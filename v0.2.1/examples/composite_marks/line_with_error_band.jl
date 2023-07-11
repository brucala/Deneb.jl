using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

base = data * Encoding("year(Year)")

band = Mark(:errorband, extent=:ci) * Encoding(
    y=field("Miles_per_Gallon:Q", title="Mean of Miles per Gallon (95% CIs)")
)

line = Mark(:line) * Encoding(y="mean(Miles_per_Gallon)")

chart = base * (band + line)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

