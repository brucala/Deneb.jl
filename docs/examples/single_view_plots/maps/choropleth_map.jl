# ---
# cover: assets/choropleth_map.png
# author: bruno
# description: Choropleth Map
# generate_cover: true
# ---

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

# save cover #src
save("assets/choropleth_map.png", chart) #src
