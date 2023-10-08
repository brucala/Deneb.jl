# ---
# cover: assets/layer_dual_axis.png
# author: bruno
# description: Layered Plot with Dual Axis
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/weather.csv")

base = data * Encoding("month(date)") * transform_filter(
    "datum.location == \"Seattle\""
)

band = Mark(:area, opacity=0.3, color="#57A44C") * Encoding(
    y=field(
        "average(temp_max)",
        axis=(title="Avg. Temperature (°C)", titleColor="#57A44C")
    ),
    y2="average(temp_min)",
)

line = Mark(:line, stroke="#5276A7", interpolate="monotone") * Encoding(
    y=field(
        "average(precipitation)",
        axis=(title="Precipitation (inches)", titleColor="#5276A7")
    )
)

chart = base * (band + line) * resolve_scale(y=:independent)

save("assets/layer_dual_axis.png", chart)  #src
