import Base.Docs: Binding, MultiDoc, DocStr

get_multidoc(__module__::Module, b::Binding) = getindex(Docs.meta(__module__), b)

function get_sigs(__module__::Module, b::Binding)
    m = get_multidoc(__module__, b)
    m.order
end

function submodules(__module__::Module)
    itr = Iterators.filter(x->(Base.moduleroot(x) == __module__ && x != __module__), Docs.modules)
    collect(itr)
end

"""
    path(multidoc, binding, sig) -> String

Returns the path of this binding with given signature.
"""
path(m::MultiDoc, b::Binding, sig) = m.docs[sig].data[:module] => m.docs[sig].data[:path]

"""
    paths(multidoc, binding) -> Generator

Returns an iterator of path of the documents of this binding.
"""
paths(m::MultiDoc, b::Binding) = (path(m, b, sig) for sig in m.order)

"""
    paths(module) -> Set

Returns an `Set` object that contains the unique relative path of doc strings.
"""
function paths(__module__::Module)
    META = Docs.meta(__module__)
    PATH = Set()
    for (b, m) in META
        for each in paths(m, b)
            push!(PATH, each)
        end
    end
    PATH
end

import Base: replace!

function gotkey(d::IdDict, k)
    for each in keys(d)
        k == each && return true
    end
    false
end

"""
    replace!(__module__, binding, str, sig)

This is a muted version of [`Docs.doc!`](@ref), it replace the original docstring with
a new docstring `str` to the docsystem of `__module__` for `binding` and signature `sig`.
"""
function replace!(__module__::Module, b::Binding, str::DocStr, @nospecialize sig = Union{})
    Docs.initmeta(__module__)
    m = get!(Docs.meta(__module__), b, MultiDoc())
    if !gotkey(m.docs, sig)
        @error "Cannot find original docs for `$b :: $sig` in module `$(__module__)`"
    end

    old = m.docs[sig]
    m.docs[sig] = str

    # inherit the rest of data
    for (k, v) in old.data
        str.data[k] = v
    end

    str.data[:binding] = b
    str.data[:typesig] = sig
    return b
end

"""
    dump_str(binding[, sig]) -> String

dump a `binding` and a signature `sig` to raw script.
"""
function dump_str end

dump_str(b::Binding) = "$(b.var)"

function dump_str(b::Binding, sig)
    if sig === Union{}
        "$(b.var)"
    else
        "$(b.var) $sig"
    end
end

function dump_str(b::Binding, sig::Type{<:Tuple})
    o = "$(b.var)"

    args = join(["::$each" for each in sig.types], ", ")
    !isempty(args) && return o * "(" * args * ")"
    o
end

function allpaths(__module__::Module)
    PATH = paths(__module__)
    for each in submodules(__module__)
        union!(PATH, allpaths(each))
    end
    PATH
end

template(mod::Module) = """@i18n $mod begin

# translation goes here

end"""

function init_i18n(__module__::Module, root)
    for (mod, each) in allpaths(__module__)
        path = joinpath(root, each)
        mkpath(dirname(path))
        write(path, template(mod)) # use a+ here? or w+ is fine?
    end
    root
end

init_i18n(root) = init_i18n(Base, root)
