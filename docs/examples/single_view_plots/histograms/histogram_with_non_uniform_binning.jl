# ---
# cover: assets/histogram_non_uniform.png
# author: bruno
# description: Histogram with non Uniform Binning
# ---

using Deneb
data =(
    bin_start=[0, 2, 5, 10, 11, 13],
    bin_end=[2, 5, 10, 11, 13, 16],
    count=rand(1:15, 6),
)
chart = Data(data) * Mark(:bar) * Encoding(
    x=field("bin_start:Q", bin="binned"),
    x2="bin_end:Q",
    y="count:Q"
)

# save cover #src
save("assets/histogram_non_uniform.png", chart) #src
