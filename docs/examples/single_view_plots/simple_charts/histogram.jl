# ---
# cover: assets/histogram.png
# author: bruno
# description: Simple Histogram
# ---

using Deneb
data = (;x=randn(200))
chart = Data(data) * Mark(:bar) * Encoding(
    x=field(:x, bin=true),
    y="count()"
)

# save cover #src
save("assets/histogram.png", chart) #src
