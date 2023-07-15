using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

chart = Data(data) * Mark(:point) * Facet(
    "MPAA Rating", type=:ordinal, columns=3
) * Encoding(
    x=field("Worldwide Gross:Q"),
    y="US DVD Sales:Q",
)

chart = Data(data) * Mark(:point) * Encoding(
    x=field("Worldwide Gross:Q"),
    y="US DVD Sales:Q",
    facet=field("MPAA Rating", type=:ordinal, columns=3),
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

