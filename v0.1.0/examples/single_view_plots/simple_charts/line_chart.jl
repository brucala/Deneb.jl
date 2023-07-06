using Deneb
x=0:0.2:25
y=sin.(x)
chart = Data((;x, y)) * Mark(:line) * Encoding("x:q", "y:q")

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

