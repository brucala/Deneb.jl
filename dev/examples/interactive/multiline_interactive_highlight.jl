using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

base = data  * Encoding("date:T", "price:Q", color="symbol:N")

points = Mark(:circle, opacity=0) * select_point(
    :hover,
    fields=[:symbol],
    on=:mouseover,
    nearest=true,
    value=(;symbol=:AAPL),
)

line = Mark(:line) * Encoding(
    size=condition(:hover, 3, 1)
)

chart = base * (points + line)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

