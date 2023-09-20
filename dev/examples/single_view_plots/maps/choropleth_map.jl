using Deneb

data = Data(
    url="https://vega.github.io/vega-datasets/data/us-10m.json",
    format=(type=:topojson, feature=:counties),
)

chart = Data(data) * Mark(:geoshape) * transform_lookup(
    :id,
    (
      data=(;url="https://vega.github.io/vega-datasets/data/unemployment.tsv"),
      key=:id,
      fields=[:rate],
    ),
) * Encoding(color="rate:Q") * projection("albersUsa") * vlspec(
    width=500, height=300
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
