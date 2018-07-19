using Localize
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

replace!(Base.Math, Docs.@var(sin), Docs.docstr("正弦函数"), Tuple{Number})
