# ---
# cover: assets/deneb_logo.png
# author: bruno
# description: Deneb.jl Logo
# ---

using Deneb

star = "M0,.5L.6,.8L.5,.1L1,-.3L.3,-.4L0,-1L-.3,-.4L-1,-.3L-.5,.1L-.6,.8L0,.5Z"
blue, green, purple, red = "#4063D8", "#389826", "#9558B2", "#CB3C33"

data = (
    x = [0.0, 0.65, 1.0, 0.2, 0.25, 0.25, 0.68],
    y = [0.55, 1.0, 0.0, 0.525, 0.275, 0.80, 0.5],
    star = [:Deneb, :Vega, :Altair, :a, :b, :c, :d],
    constellation = [:Cygnus, :Lyra, :Aquila, :Cygnus, :Cygnus, :Cygnus, :Cygnus]
)

scale=(
    domain=[:Deneb, :Vega, :Altair],
    range=[red, green, purple],
)

base = Data(data) * Encoding(
    x=field("x:Q", axis=nothing),
    y=field("y:Q", axis=nothing),
) * vlspec(background="")

cygnus = Mark(
    :point, shape=star, size=1000, color=blue, filled=true,
) * transform_filter(
    "datum.constellation == 'Cygnus' & datum.star != 'Deneb'"
)

summer_triangle = Mark(
    :point, shape=star, size=10000, filled=true
) * Encoding(
    color=field(:star; legend=nothing, scale),
    tooltip=[field(:star)],
) * config(:view, stroke="")


chart = base * (cygnus + summer_triangle)

# save cover #src
# svg so transparency works # src
save("assets/deneb_logo.svg", chart) #src
