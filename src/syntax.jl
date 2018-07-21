function is_i18n_docstring(ex)
    ex.head === :macrocall && length(ex.args) == 3 && last(ex.args) isa String
end

function check_continous(line_string::LineNumberNode, content::String, line_binding::LineNumberNode)
    n = countlines(IOBuffer(content))
    line_string + n + 2 == line_binding
end

get_docstr(docstring) = Docs.docstr(last(docstring.args))

function ati18n(source::LineNumberNode, mod::Module, mex, def)
    def.head !== :block && error("Expect @i8n mod begin ... end")
    total = length(def.args)

    i18nex = Expr(:block)
    for i in 1:4:total
        nline_str, docstring, nline_binding, binding_ex = def.args[i], def.args[i+1], def.args[i+2], def.args[i+3]

        is_i18n_docstring(docstring) || error("This is not an i18n docstring")

        # functions
        b = @capture(binding_ex, f_(args__)|f_(args__; kwargs__)) ? f : binding_ex

        b = Symbol(b)
        mex = :($mex)
        ex = quote
            replace!($(esc(mex)), Docs.@var($(b)), $(get_docstr(docstring)), $(esc(Docs.signature(binding_ex))))
        end

        push!(i18nex.args, ex)
    end
    i18nex
end

macro i18n(x...)
   ati18n(__source__, __module__, x...)
end
