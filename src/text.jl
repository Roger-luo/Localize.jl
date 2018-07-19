# Inspired by Python's gettext, but in a Julian way.

"""
    Translation

This holds the contents of all localizations.
"""
struct Translation
    content::String # original English content
    translation::Dict{Symbol, Any}
end

Translation(content::String) = Translation(content, Dict{Symbol, Any}())

Base.getindex(text::Translation, locale::Symbol) = getindex(text.translation, locale)
Base.setindex!(text::Translation, trans, locale::Symbol) = setindex!(text.translation, trans, locale)
Base.show(io::IO, t::Translation) = Base.show(io, t.content)

# make gettext people happy
translate(text::Translation, locale::Symbol) = text.translation[locale]
