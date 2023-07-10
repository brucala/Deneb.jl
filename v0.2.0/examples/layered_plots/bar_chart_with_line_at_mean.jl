using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/wheat.json")

bar = Mark(:bar) * Encoding("year:O", "wheat:Q")

rule = Mark(:rule, color=:red) * Encoding(y="mean(wheat):Q")

chart = data * (bar + rule) * vlspec(width=600)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

