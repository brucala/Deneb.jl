# ---
# cover: assets/line_chart.png
# author: bruno
# description: Simple Line Chart
# generate_cover: true
# ---

using Deneb
x=0:0.2:25
y=sin.(x)
chart = Data((;x, y)) * Mark(:line) * Encoding("x:q", "y:q")

# save cover #src
save("assets/line_chart.png", chart) #src


# ## Using Vega-Lite's sequence generator

chart = Data(
    :sequence, start=0, stop=25, step=0.2, as=:x
) * transform_calculate(
    y="sin(datum.x)"
) * Mark(:line) * Encoding("x:q", "y:q")
