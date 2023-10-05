# ---
# cover: assets/bar_chart_highlight_select.png
# author: bruno
# description: Bar Chart with Highlighting on Hover and Selection on Click
# generate_cover: true
# ---

using Deneb

data = (a=string.('A':'L'), b=rand(0:100, 12))

chart = Data(data) * Mark(
    :bar,
    stroke=:black,
    cursor=:pointer,
    width=(;band=0.9),
) * select_point(
    :highlight, on=:mouseover
) * select_point(
    :select
) * Encoding(
    "a:n",
    "b:q",
    fillOpacity=condition(:select, 1, 0.3),
    strokeWidth=condition(
        [:select => 2, :highlight => 1],
        0,
        empty=[false, false],
    )
)

# save cover #src
save("assets/bar_chart_highlight_select.png", chart) #src
