# ---
# cover: assets/error_bars_stdev.png
# author: bruno
# description: Error Bars with Standard Deviation
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/barley.json")

base = data * Encoding(y=:variety)

errors = Mark(:errorbar, extent=:stdev) * Encoding(
    x=field("yield:Q", scale=(;zero=false))
)

points = Mark(:point, filled=true, color=:black) * Encoding("mean(yield)")

chart = base * (errors + points)

save("assets/error_bars_stdev.png", chart)  #src
