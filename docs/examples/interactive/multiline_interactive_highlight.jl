# ---
# cover: assets/multiline_interactive_highlight.png
# author: bruno
# description: Multiline interactive highlight
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

base = data  * Encoding("date:T", "price:Q", color="symbol:N")

points = Mark(:circle, opacity=0) * Params(
    name=:hover,
    select=(type=:point, fields=[:symbol], on=:mouseover, nearest=true),
    value=(;symbol=:AAPL),
)

line = Mark(:line) * Encoding(
    size=condition(:hover, 3, 1)
)

chart = base * (points + line)

# !!! note "Why the points layer?"
#     Because of a VegaLite's [limitation](https://vega.github.io/vega-lite/docs/selection.html#current-limitations-1)
#     in the `nearest`` property.

# save cover #src
save("assets/multiline_interactive_highlight.png", chart) #src
