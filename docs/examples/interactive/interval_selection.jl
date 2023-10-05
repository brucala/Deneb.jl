# ---
# cover: assets/interval_selection.png
# author: bruno
# description: Interval Selection
# generate_cover: true
# ---

# !!! note "Tip"
#     Try selecting and dragging an interval on the bottom chart

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/sp500.csv")

base = data * Mark(:area) * Encoding(
    "date:T", "price:Q"
) * vlspec(width = 600)

upper = Encoding(
    x=(
        title="",
        scale=(;domain=param(:brush)),
    )
)

lower = select_interval(
    :brush,
    encodings=[:x],
) * vlspec(height=60)

chart = base * [upper; lower]

# save cover #src
save("assets/interval_selection.png", chart) #src
