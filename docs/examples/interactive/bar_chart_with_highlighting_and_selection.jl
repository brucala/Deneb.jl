# ---
# cover: assets/bar_chart_highlight_select.png
# author: bruno
# description: Bar Chart with Highlighting on Hover and Selection on Click
# ---

using Deneb

data = (a=string.('A':'L'), b=rand(0:100, 12))

chart = Data(data) * Mark(
    :bar,
    stroke=:black,
    cursor=:pointer,
    width=(;band=0.9),
) * Params(
    name=:highlight,
    select=(type=:point, on=:mouseover),
) * Params(
    name=:select,
    select=:point,
) * Encoding(
    "a:n",
    "b:q",
    fillOpacity=condition(:select, 1, 0.3),
    strokeWidth=(
        condition=[
            (param=:select, empty=false, value=2),
            (param=:highlight, empty=false, value=1),
        ],
        value=0,
    )
)

# save cover #src
save("assets/bar_chart_highlight_select.png", chart) #src
