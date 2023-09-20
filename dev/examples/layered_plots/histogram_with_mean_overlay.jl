using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

bar = Mark(:bar) * Encoding(
    x=field("IMDB Rating:Q", bin=true),
    y="count()"
)

rule = Mark(:rule, color=:red, size=5) * Encoding(x="mean(IMDB Rating)")

chart = data * (bar + rule)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
