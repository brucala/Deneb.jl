using Deneb
x = repeat(0:0.1:1, inner=11)
y = repeat(0:0.1:1, outer=11)
z = x.^2 .+ y.^2
chart = Data((;x, y, z)) * Mark(:rect) * Encoding(
    "x:o",
    "y:o",
    color="z:q"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

