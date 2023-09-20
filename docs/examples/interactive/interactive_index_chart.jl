# ---
# cover: assets/interactive_index_chart.png
# author: bruno
# description: Interactive Index Chart
# ---

using Deneb

set_theme!(:default_no_tooltip)

stocks_url = "https://vega.github.io/vega-datasets/data/stocks.csv"

base = Data(url=stocks_url) * Encoding(x=field("date:T", axis=nothing))

points = Mark(:point, opacity=0) * select_point(
    :index,
    encodings=:x,
    on=:mouseover,
    nearest=true,
    value=(;x=(;year=2005)),
)

lines = Mark(:line) * Encoding(
    y=field("indexed_price:Q", axis=(;format="%")),
    color="symbol:N"
) * transform_lookup(
    :symbol, (param=:index, key=:symbol),
) * transform_calculate(
    indexed_price="datum.index && datum.index.price > 0 ? (datum.price - datum.index.price)/datum.index.price : 0",
)

rule = Mark(:rule, color=:firebrick, strokeWidth=0.5)

label = Mark(:text, color=:firebrick, align=:center, fontWeight=100, y=310) * Encoding(
    text="yearmonth(date)",
)

label_rule = transform_filter(param(:index)) * (rule + label)

chart = base * (points + lines + label_rule) * vlspec(
    width=650, height=300
)

# save cover #src
save("assets/interactive_index_chart.png", chart) #src
