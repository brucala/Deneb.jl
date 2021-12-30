# ---
# cover: assets/repeated_wrapped_histogram.png
# author: bruno
# description: Repeated Wrapped Histogram
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = Data(data) * Mark(:bar) * Repeat(
    ["Horsepower", "Miles_per_Gallon", "Acceleration", "Displacement"],
    columns=2
) * Encoding(
    x=(field=(;repeat=:repeat), bin=true),
    y="count()",
    color=:Origin,
)

# save cover #src
save("assets/repeated_wrapped_histogram.png", chart) #src
