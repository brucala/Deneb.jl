JSON.json(s::AbstractSpec) = json(value(spec(s)))
JSON.json(s::AbstractSpec, indent) = json(value(spec(s)), indent)

function Base.show(io::IO, m::MIME"text/plain", s::AbstractSpec)
    print(io, "$(typeof(s)): \n", json(s, 2))
end
