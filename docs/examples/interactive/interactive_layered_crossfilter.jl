# ---
# cover: assets/interactive_crossfilter.png
# author: bruno
# title: Interactive Layered Crossfilter
# ---

using Deneb

data = Data(
    url="https://vega.github.io/vega-datasets/data/flights-2k.json",
    format=(; parse=(; date=:date)),
)

base = Mark(:bar) * Encoding(
    x=(field=(; repeat=:column), bin=(; maxbins=20)),
    y="count()"
)

histos = base * select_interval(
    :brush, encodings=[:x]
) * Encoding(color=(; value="#ddd")) * vlspec(
    width=200, height=200
)

filter = base * transform_filter(param(:brush))

chart = data * transform_calculate(
    time="hours(datum.date)",
) * Repeat(
    column=[:distance, :delay, :time]
) * (histos + filter)

# save cover #src
save("assets/interactive_crossfilter.png", chart) #src
