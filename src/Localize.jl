module Localize

using Compat

# string literals
export @zh_str, @fr_str, @lang

# additional language string interface
export language, locale

include("strings.jl")

end # module
