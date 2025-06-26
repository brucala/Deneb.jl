using Deneb
data = (a=string.('A':'L'), b=rand(0:100, 12))
chart = Data(data) * Mark(:bar) * Encoding("a:n", "b:q")

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
