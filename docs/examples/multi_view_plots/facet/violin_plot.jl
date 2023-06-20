# ---
# cover: assets/violin_plot.png
# author: bruno
# description: Violin PLot
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = data * Mark(:area, orient=:horizontal) * transform_density(
    :Miles_per_Gallon,
    as=[:Miles_per_Gallon, :density],
    extent=[5, 50],
    groupby=:Origin,
) * Encoding(
    x=field(
        "density:Q",
        stack=:center,
        axis=(labels=false, values=[0], grid=false, ticks=true),
        impute=nothing,
        title=nothing,
    ),
    y="Miles_per_Gallon:Q",
    color="Origin:N",
    column=field(
        "Origin:N",
        spacing=0,
        header=(titleOrient=:bottom, labelOrient=:bottom, labelPadding=0),
    )
) * vlspec(
    width=100,
    config=(;view=(;stroke=""))
)

# save cover #src
save("assets/violin_plot.png", chart) #src
