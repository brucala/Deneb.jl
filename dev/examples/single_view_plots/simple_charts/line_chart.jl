using Deneb
x=0:0.2:25
y=sin.(x)
chart = Data((;x, y)) * Mark(:line) * Encoding("x:q", "y:q")

chart = Data(
    :sequence, start=0, stop=25, step=0.2, as=:x
) * transform_calculate(
    y="sin(datum.x)"
) * Mark(:line) * Encoding("x:q", "y:q")

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
