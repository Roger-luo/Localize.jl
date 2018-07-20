module Localize

using Compat, MacroTools

#######################
#    Language Strings

# string literals
export @zh_str, @fr_str, @lang

# additional language string interface
export language, locale

include("strings.jl")

########################
#     Doc System Utils

export get_multidoc, get_sigs, submodules, path, paths, allpaths, dump_str, replace!, init_i18n

include("docsys.jl")

export Translation, translate
include("text.jl")

export @i18n

include("syntax.jl")

end # module
