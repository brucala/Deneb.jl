# ---
# cover: assets/interactive_pan_and_zoom.png
# author: bruno
# description: Interactive Pan and Zoom
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = data * Mark(:circle, clip=true) * Encoding(
    x=field("Horsepower:Q", scale=(;domain=[75, 150])),
    y=field("Miles_per_Gallon:Q", scale=(;domain=[20, 40])),
    size="Cylinders:Q",
)

chart * interactive()

# save cover #src
save("assets/interactive_pan_and_zoom.png", chart) #src

# ## Bind `x` encoding only

chart * interactive(bindy=false)

# ## Bind `y encoding only

chart * interactive(bindx=false)

# ## Hold shift for `y` encoding

chart * interactive(shift_on_y=true)
