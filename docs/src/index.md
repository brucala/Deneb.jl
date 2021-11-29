# Deneb gallery

## Simple bar chart

```@example
using Deneb
data = (a=string.('A':'I'), b=rand(0:100, 9))
Data(data) * Mark(:bar, tooltip=true) * Encoding("a:n", "b:q")
```

## Grouped bar chart

Available from Vega v5 on:
```@example grouped-bar
using Deneb
data = (
    category=collect("AAABBBCCC"),
    group=collect("xyzxyzxyz"),
    value=rand(9)
)
Data(data) * Mark(:bar, tooltip=true) * Encoding(
    :category,
    "value:q",
    xOffset=(;field=:group),
    color=(;field=:group)
)
```
Using the column encoding:
```@example grouped-bar
Data(data) * Mark(:bar, tooltip=true) * Encoding(
    :group,
    "value:q",
    color=(;field=:group),
    column=(;field=:category),
)
```
