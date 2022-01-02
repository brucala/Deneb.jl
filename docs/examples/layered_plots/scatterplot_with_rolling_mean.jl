# ---
# cover: assets/scatterplot_with_rolling_mean.png
# author: bruno
# description: Scatter Plot with Rolling Mean
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/seattle-weather.csv")

line = Mark(:line, color=:red, size=3) * Transform(
    window=[field(:temp_max, op=:mean, as=:rolling_mean)],
    frame=[-15, 15],
) * Encoding("date:T", "rolling_mean:Q")

points = Mark(:point, opacity=0.3) * Encoding(
    "date:T",
    y=field("temp_max:Q", title="Max Temperature and Rolling Mean")
)

chart = data * (points + line) * vlspec(width=400)

save("assets/scatterplot_with_rolling_mean.png", chart)  #src
