# ---
# cover: assets/table_bubble_plot.png
# author: bruno
# description: Table Bubble Plot (Github Punch Card)
# generate_cover: true
# ---

# Punchcard Visualization like on Github. The day on y-axis uses a custom order from Monday to Sunday.  The sort property supports both full day names (e.g., 'Monday') and their three letter initials (e.g., 'mon') -- both of which are case insensitive.

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/github.csv")
chart = Data(data) * Mark(:circle) * Encoding(
    x="hours(time):O",
    y=field(
        "day(time):O",
        sort=[:mon, :tue, :wed, :thu, :fri, :sat, :sun]
    ),
    size="sum(count):Q"
)

# save cover #src
save("assets/table_bubble_plot.png", chart) #src
