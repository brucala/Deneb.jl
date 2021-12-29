# ---
# cover: assets/aggregate_bar_chart.png
# author: bruno
# description: Aggregate Bar Chart
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/population.json")

chart = data * Mark(:bar) * Transform(
    filter="datum.year == 2000"
)* Encoding(
    x=field("sum(people)", title=:population),
    y="age",
)

save("assets/aggregate_bar_chart.png", chart)  #src
