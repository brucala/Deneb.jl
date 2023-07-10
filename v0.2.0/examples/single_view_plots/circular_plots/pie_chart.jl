using Deneb

data = (
    category=1:6,
    value=rand(1:10, 6)
)
chart = Data(data) * Mark(:arc) * Encoding(
    theta="value:q",
    color="category:n"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

