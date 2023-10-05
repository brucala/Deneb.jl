# ---
# cover: assets/aggregate_bar_chart.png
# author: bruno
# description: Aggregate Bar Chart
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/population.json")

chart = data * Mark(:bar) * transform_filter(
    "datum.year == 2000"
)* Encoding(
    x=field("sum(people)", title=:population),
    y="age",
) * vlspec(height=(;step=18))

save("assets/aggregate_bar_chart.png", chart)  #src
