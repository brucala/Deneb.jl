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

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
