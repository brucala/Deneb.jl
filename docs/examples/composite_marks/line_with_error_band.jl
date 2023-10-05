# ---
# cover: assets/error_band_ci.png
# author: bruno
# description: Line with Confidence Interval Band
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

base = data * Encoding("year(Year)")

band = Mark(:errorband, extent=:ci) * Encoding(
    y=field("Miles_per_Gallon:Q", title="Mean of Miles per Gallon (95% CIs)")
)

line = Mark(:line) * Encoding(y="mean(Miles_per_Gallon)")

chart = base * (band + line)

save("assets/error_band_ci.png", chart)  #src
