function Base.show(io::IO, ::MIME"text/plain", l::Leg)
    ioc = IOContext(io, :compact => true, :limit => true)
    print(ioc, "Leg with ")
    println(io, isempty(l.BAx) ? " AB <=> BA:" : " asymmetric AB:")
    println(ioc, rpad(" label_A = ", 10), l.label_A)
    println(ioc, rpad(" label_B = ", 10), l.label_B)
    print(ioc, rpad(" bb_utm = ", 10), repr(typeof(l.bb_utm)), "(")
        println(ioc, l.bb_utm.corner1, " : ", l.bb_utm.corner2, ")")
    println(ioc, rpad(" ABx = ", 10), "[",  l.ABx[1], "  …  ", l.ABx[end], "] (", length(l.ABx), " elements)")
    print(ioc, rpad(" ABy = ", 10), "[",  l.ABy[1], "  …  ", l.ABy[end], "] (", length(l.ABy), " elements)")
    if ! isempty(l.BAx)
        println(ioc)
        println(ioc, rpad(" BAx = ", 10), "[",  l.BAx[1], "  …  ", l.BAx[end], "] (", length(l.BAx), " elements)")
        print(ioc, rpad(" BAy = ", 10), "[",  l.BAy[1], "  …  ", l.BAy[end], "] (", length(l.BAy), " elements)")
    end
end

function Base.show(io::IO, l::Leg)
    ioc = IOContext(io, :compact => true, :limit => true)
    print(ioc, "Leg(")
    print(ioc, "; text_A = \"", l.label_A.text, "\"")
    print(ioc, ", prominence_A = ", l.label_A.prominence)
    print(ioc, ", text_B = \"", l.label_B.text, "\"")
    print(ioc, ", prominence_B = ", l.label_B.prominence)
    print(io, ", ABx = ", l.ABx)
    print(io, ", ABy = ", l.ABy)
    if ! isempty(l.BAx)
        print(io, ", BAx = ", l.BAx)
        print(io, ", BAy = ", l.BAy)
    end
   print(ioc, ")")
end

function Base.show(io::IO, l::Label)
    print(io, repr(typeof(l)), "(\"")
    printstyled(io, l.text, color = :green)
    print(io, "\", ")
    printstyled(io, l.prominence, color = l.prominence < 1.5 ? :bold : :normal)
    print(io, ", ")
    printstyled(io, round(l.x; digits = 1), color = :blue)
    print(io, ", ")
    printstyled(io, round(l.y; digits = 1), color = :blue)
    print(io, ")")
end
function Base.show(io::IO, m::ModelSpace)
    print(io, repr(typeof(m)), "(")
    vs = fieldnames(typeof(m))
    for (i, fi) in enumerate(vs)
        print(io, "\t", rpad(fi, 22), " = ")
        printstyled(io, getfield(m, fi),  color=:green)
        if i < length(vs)
            println(io, ", ")
        end
    end
    print(io, ")")
end
function Base.show(io::IO, l::LabelPaperSpace)
    print(io, repr(typeof(l)), "(")
    vs = fieldnames(typeof(l))
    for (i, fi) in enumerate(vs)
        if i !== 1
            print(io, "\t\t")
        end
        print(io, rpad(fi, 22), " = ")
        va = getfield(l, fi)
        printstyled(io, repr(va),  color=:green)
        if i < length(vs)
            println(io, ", ")
        end
    end
    print(io, ")")
end