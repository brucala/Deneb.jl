JSON.json(s::Spec) = json(value(s))
JSON.json(s::Spec, indent) = json(value(s), indent)

JSON.json(s::AbstractSpec) = json(spec(s))
JSON.json(s::AbstractSpec, indent) = json(spec(s), indent)
