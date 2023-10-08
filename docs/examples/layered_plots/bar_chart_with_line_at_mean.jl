# ---
# cover: assets/bar_chart_with_line_at_mean.png
# author: bruno
# description: Bar Chart with Line at Mean
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/wheat.json")

bar = Mark(:bar) * Encoding("year:O", "wheat:Q")

rule = Mark(:rule, color=:red) * Encoding(y="mean(wheat):Q")

chart = data * (bar + rule) * vlspec(width=600)

save("assets/bar_chart_with_line_at_mean.png", chart)  #src
