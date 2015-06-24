import Escher: @api

@api test1 => TestType1 begin
    arg(a::FloatingPoint)
end
@fact test1(3) => TestType1(3.0)

@api testsub => TestSubType <: Number begin
    arg(a::FloatingPoint)
end
@fact testsub(3) => TestSubType(3.0)

@api test2 => TestType2 begin
    typedarg(a::FloatingPoint)
    arg(b::Int)
    curry(x::Int)
end

println(macroexpand(:(@api test2 => TestType2 begin
    typedarg(a::FloatingPoint)
    arg(b::Int)
    curry(x::Int)
end)))

@fact_throws test2(2, 3, 4) # Because 2 should be float
@fact test2(2.0, 3, 4) => TestType2(2.0, 3, 4)
@fact test2(2.0, 3)(4) => TestType2(2.0, 3, 4)

@api test3 => TestType3 begin
    typedarg(a::FloatingPoint)
    arg(b::Int)
    curry(x::Int)
    kwarg(p::Any="black")
    typedkwarg(q::FloatingPoint=1)
end

@fact_throws test3(2, 3, 4) # Because 2 should be float
@fact test3(2.0, 3, 4) => TestType3(2.0, 3, 4, "black", 1)
@fact test3(2.0, 3)(4) => TestType3(2.0, 3, 4, "black", 1)
@fact test3(2.0, 3, 4, p=:white) => TestType3(2.0, 3, 4, :white, 1)
@fact test3(2.0, 3, q=5.0)(4) => TestType3(2.0, 3, 4, "black", 5.0)
@fact_throws test3(2.0, 5, 4, q=1)

abstract A
immutable B<:A end

#@show macroexpand(:(
@api test4 => Test4{P <: A} <: Tile begin
    typedarg(a::AbstractArray=Integer[])
    arg(b::P)
    curry(c::Int)
end
#))
println(test4(B())(2))

@api code => Code <: A begin
    arg(language::String="julia")
    arg(code::Any)
end
