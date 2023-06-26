# ---
# cover: assets/deneb_logo.svg
# author: bruno
# description: Deneb.jl Logo
# ---

using Deneb

star_shape = "M0,.5L.6,.8L.5,.1L1,-.3L.3,-.4L0,-1L-.3,-.4L-1,-.3L-.5,.1L-.6,.8L0,.5Z"
blue, green, purple, red = "#4063D8", "#389826", "#9558B2", "#CB3C33"

star(star, constellation, magnitude, az, alt) = (; star, constellation, magnitude, az, alt)

# azimuth/altitude taken from arbitrary time/location for convenient orientation
data = [
    star(:Deneb, :Cygnus, 1.25, 40.8, 17.0),
    star(:Vega, :Lyra, 0, 63.1, 29.3),
    star(:Altair, :Aquila, 0.75, 73.3, -3.4),
    star(:Albireo, :Cygnus, 3.05, 63.9, 13.8),
    star(:Sadir, :Cygnus, 2.2, 47.6, 15.45),
    star(:Fawaris, :Cygnus, 2.9, 49.2, 23.72),
    star(:Aljanah, :Cygnus, 2.45, 48.6, 5.72),
    star("η Cygni", :Cygnus, 3.85, 54.6, 15.1),
]

color_scale = (
    domain=[:Deneb, :Vega, :Altair],
    range=[red, green, purple],
)

base = Data(data) * Encoding(
    longitude="az:Q",
    latitude="alt:Q",
    tooltip=[field(:star), field(:constellation), field(:magnitude)],
)

cygnus = Mark(
    :point, shape=star_shape, color=blue, filled=true, opacity=1
) * transform_filter(
    "datum.constellation == 'Cygnus' & datum.star != 'Deneb'"
) * Encoding(
    size=field(
        "magnitude:Q",
        legend=nothing,
        scale=(type=:log, reverse=true, range=[200, 1000])
    )
)

summer_triangle = Mark(
    :point, shape=star_shape, size=10000, filled=true, opacity=1
) * Encoding(
    color=field(:star; legend=nothing, scale=color_scale),
) * config(:view, stroke="")

logo = base * (cygnus + summer_triangle)

# save cover #src
# svg so transparency works #src
save("assets/deneb_logo.svg", logo * vlspec(background="")) #src
