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
