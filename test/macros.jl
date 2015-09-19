import Escher: @api
using Base.Test

comparefields(x, y) =
    try
       Bool[getfield(x, f) == getfield(y, f) for f in union(fieldnames(x), fieldnames(y))] |> all
    catch
        false
    end


@api test1 => TestType1 begin
    arg(a::AbstractFloat)
end
@test test1(3) == TestType1(3.0)

@api testsub => (TestSubType <: Number) begin
    arg(a::AbstractFloat)
end
@test testsub(3) == TestSubType(3.0)

@api test2 => TestType2 begin
    typedarg(a::AbstractFloat)
    arg(b::Int)
    curry(x::Int)
end

@test_throws MethodError test2(2, 3, 4) # Because 2 should be float
@test comparefields(test2(2.0, 3, 4), TestType2(2.0, 3, 4))
@test comparefields(test2(2.0, 3)(4), TestType2(2.0, 3, 4))

@api test3 => TestType3 begin
    typedarg(a::AbstractFloat)
    arg(b::Int)
    curry(x::Int)
    kwarg(p::Any="black")
    typedkwarg(q::AbstractFloat=1.0)
end

@test_throws MethodError test3(2, 3, 4) # Because 2 should be float
@test_throws TypeError test3(2.0, 5, 4, q=1) # q should be float

@test comparefields(test3(2.0, 3, 4), TestType3(2.0, 3, 4, "black", 1.0))
@test comparefields(test3(2.0, 3)(4), TestType3(2.0, 3, 4, "black", 1.0))
@test comparefields(test3(2.0, 3, 4, p=:white), TestType3(2.0, 3, 4, :white, 1))
@test comparefields(test3(2.0, 3, q=5.0)(4), TestType3(2.0, 3, 4, "black", 5.0))

abstract A
immutable B<:A end

#@show macroexpand(:(
@api test4 => (Test4{P <: A} <: Tile) begin
    typedarg(a::AbstractArray=Integer[])
    arg(b::P)
    curry(c::Int)
end
#))
@test comparefields(test4(B())(2), test4(Integer[], B(), 2))
