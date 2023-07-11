using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

chart = Data(data) * Mark(:line) * Repeat(
    layer = ["US Gross", "Worldwide Gross"]
) * Encoding(
    x=field("IMDB Rating:Q", bin=true),
    y=(
        field=(;repeat=:layer),
        aggregate=:mean,
        title="Mean of US and Worldwide",
    ),
    color=(;datum=(;repeat=:layer)),
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

