using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = data * Mark(:circle, clip=true) * Encoding(
    x=field("Horsepower:Q", scale=(;domain=[75, 150])),
    y=field("Miles_per_Gallon:Q", scale=(;domain=[20, 40])),
    size="Cylinders:Q",
)

chart * interactive_scales()

chart * interactive_scales(bindy=false)

chart * interactive_scales(bindx=false)

chart * interactive_scales(shift_on_y=true)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

