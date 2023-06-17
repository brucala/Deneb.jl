# ---
# cover: assets/scatterplot_with_links.png
# author: bruno
# description: Scatterplot with External Links
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = data * Mark(:point) * transform_calculate(
    url="'https://www.google.com/search?q=' + datum.Name",
) * Encoding(
    "Horsepower:Q",
    "Miles_per_Gallon:Q",
    color=:Origin,
    tooltip=:Name,
    href=:url,
)

# save cover #src
save("assets/scatterplot_with_links.png", chart) #src
