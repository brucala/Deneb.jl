# ---
# cover: assets/bar_chart_with_labels.png
# author: bruno
# description: Bar Chart with Labels
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

base = data * Encoding("mean(IMDB Rating)", "Major Genre")

bar = Mark(:bar)

text = Mark(
    :text, align=:left, baseline=:middle, dx=3
) * Encoding(
    text=field("mean(IMDB Rating)", format=".2f")
)

chart = base * (bar + text) * vlspec(height=450)

save("assets/bar_chart_with_labels.png", chart)  #src
