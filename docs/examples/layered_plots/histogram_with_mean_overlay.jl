# ---
# cover: assets/histogram_with_mean.png
# author: bruno
# description: Histogram with Global Mean Overlay
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

bar = Mark(:bar) * Encoding(
    x=field("IMDB Rating:Q", bin=true),
    y="count()"
)

rule = Mark(:rule, color=:red, size=5) * Encoding(x="mean(IMDB Rating)")

chart = data * (bar + rule)

save("assets/histogram_with_mean.png", chart)  #src
