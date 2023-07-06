using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

base = data * Encoding("mean(IMDB Rating)", "Major Genre")

bar = Mark(:bar)

text = Mark(
    :text, align=:left, baseline=:middle, dx=3
) * Encoding(
    text=field("mean(IMDB Rating)", format=".2f")
)

chart = base * (bar + text) * vlspec(height=450)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

