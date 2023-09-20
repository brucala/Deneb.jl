using Deneb

data = (
    category=string.('a':'f'),
    value=rand(1:10, 6)
)

base = Data(data) * Encoding(
    theta=field("value:q", stack=true),
    color=field(:category, legend=nothing),
)

pie = Mark(:arc, outerRadius=120)

labels = Mark(:text, radius=140, size=20) * Encoding(text=:category)

chart = base * (pie + labels)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
