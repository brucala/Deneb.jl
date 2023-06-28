using Deneb

set_theme!(:default_no_tooltip)

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

x, y, color = "date:T", "price:Q", "symbol:N"

base_encoding = Encoding(; x, y, color)

points = Mark(:point) * select_point(
    :label,
    encodings=:x,
    on=:mouseover,
    nearest=true,
    value=(;x=(;year=2008)),
) * Encoding(
    opacity=condition(:label, 1, 0)
)

line = Mark(:line)

graph = base_encoding * (line + points)

date_filter = transform_filter(param(:label))

rule = Mark(:rule, color=:grey) * Encoding(; x)

white_text = Mark(:text, align=:left, dx=5, dy=-5, stroke=:white, strokeWidth=2)

color_text = Mark(:text, align=:left, dx=5, dy=-5)

text = base_encoding * Encoding(text="price:Q") * (white_text + color_text)

labels = date_filter * (rule + text)

chart = data * (graph + labels)

set_theme!(:default)  #hide

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

