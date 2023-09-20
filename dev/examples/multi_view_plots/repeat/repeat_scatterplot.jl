using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/penguins.json")

chart = Data(data) * Mark(:point) * Repeat(
    row=[
        "Beak Length (mm)",
        "Beak Depth (mm)",
        "Flipper Length (mm)",
        "Body Mass (g)"
      ],
      column=[
        "Body Mass (g)",
        "Flipper Length (mm)",
        "Beak Depth (mm)",
        "Beak Length (mm)"
      ],
) * Encoding(
    x=(
        field=(;repeat=:column),
        type=:quantitative,
        scale=(;zero=false)
    ),
    y=(
        field=(;repeat=:row),
        type=:quantitative,
        scale=(;zero=false)
    ),
    color=:Species,
) * vlspec(
    width=150, height=150
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
