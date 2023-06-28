using Deneb
data = (;x=randn(200))
chart = Data(data) * Mark(:bar) * Encoding(
    x=field(:x, bin=true),
    y="count()"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

