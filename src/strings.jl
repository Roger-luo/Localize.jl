"""
    LangString <: AbstractString

String with a language tag.

    LangString{locale}(content)

A language tag is the locale name (without format), e.g
`:zh_CN`, `:fr_FR`. A full list of locales can be found
here:

https://docs.moodle.org/dev/Table_of_locales
"""
struct LangString{L, T <: AbstractString} <: AbstractString
    content::T

    LangString{L}(content::T) where {L, T} = new{L, T}(content)
    LangString(content::T) where T = new{:en_US, T}(content) # default language is English
end

"""
    language(s) -> String

Returns the name of language in "<locale/local language>" format
"""
function language end

"""
    locale(s) -> String

Return the locale, e.g
`:zh_CN.UTF-8`, `:fr_FR.UTF-8`. A full list of locales can be found
here:

https://docs.moodle.org/dev/Table_of_locales
"""
function locale end

language(s::LangString{:zh_CN}) = "zh_CN/中文"
language(s::LangString{:zh_TW}) = "zh_TW/中文"
language(s::LangString{:fr_FR}) = "fr_FR/français"

locale(s::LangString{L, String}) where L = "$L.UTF-8"

# forward String interface
Base.write(io::IO, s::LangString) = Base.write(io::IO, s.content)
Base.show(io::IO, s::LangString) = Base.show(io, s.content)

Compat.firstindex(s::LangString) = Compat.firstindex(s.content)
Compat.lastindex(s::LangString) = Compat.lastindex(s.content)

Base.start(s::LangString) = start(s.content)
Base.next(s::LangString, i) = next(s.content, i)
Base.done(s::LangString, i) = done(s.content, i)
if isdefined(Base, :iterate)
    Base.iterate(s::LangString, i::Int) = iterate(s.content, i)
end

Base.nextind(s::LangString, i::Int) = nextind(s.content, i)
Base.prevind(s::LangString, i::Int) = prevind(s.content, i)
Base.eachindex(s::LangString) = eachindex(s.content)
Base.length(s::LangString) = length(s.content)

Base.getindex(s::LangString, i::Integer) = getindex(s.content, i)
Base.getindex(s::LangString, i::Int) = getindex(s.content, i) # for method ambig in Julia 0.6
Base.getindex(s::LangString, i::UnitRange{Int}) = getindex(s.content, i)
Base.getindex(s::LangString, i::UnitRange{<:Integer}) = getindex(s.content, i)
Base.getindex(s::LangString, i::AbstractVector{<:Integer}) = getindex(s.content, i)
Compat.codeunit(s::LangString, i::Integer) = codeunit(s.content, i)
Compat.codeunit(s::LangString) = codeunit(s.content)
Compat.ncodeunits(s::LangString) = ncodeunits(s.content)
Compat.codeunits(s::LangString) = codeunits(s.content)
Base.sizeof(s::LangString) = sizeof(s.content)
Base.isvalid(s::LangString, i::Integer) = isvalid(s.content, i)
Base.pointer(s::LangString) = pointer(s.content)
Base.IOBuffer(s::LangString) = IOBuffer(s.content)
Base.unsafe_convert(T::Union{Type{Ptr{UInt8}},Type{Ptr{Int8}},Cstring}, s::LangString) = Base.unsafe_convert(T, s.content)

struct LangMismatchError{T <: Tuple} <: Exception
    got::T
end

LangMismatchError(langs::Symbol...) = LangMismatchError(langs)

Base.show(io::IO, e::LangMismatchError{L}) where L = print(io, "Language mismatch, got: ", e.got)

macro zh_str(s)
    LangString{:zh_CN}(s)
end

macro fr_str(s)
    LangString{:fr_FR}(s)
end

macro lang(locale, s)
    LangString{locale}(s)
end
