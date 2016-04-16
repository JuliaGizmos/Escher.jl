Developer Docs
==============

## The Basics

Code contained in the `basics/` directory involves code required to bootstrap Escher.

Firstly, it contains the definition of the Tile abstract type of which all renderable objects in Escher are subtypes. A Tile has the contract that it has a `render(tile, state)` method that produces a `Patchwork.Elem` object which represents its DOM rendition. This is the exact datastructure that gets replicated in the browser. The `state` object gets passed around when a Tile renders other tiles contained by it. It's just a plain dictionary, so the `render` methods can decide what to use it for.

As user of Escher goes around creating `Tile` or `Signal{T<:Tile}` objects. A "Sinal of Tiles" gets rendered as a changing UI by the Escher server mechanism that is described in a later section. You can construct these signals using input signals from various sources, which are discussed in the "Interaction" subsection.


Tile is the common currency which is used by all functionality in Escher. There are many functions in Escher which you can use to generate tiles from other Julia values (e.g. primitive types, DataFrames, plots), while the rest of the functions take Tiles as arguments and return either a modified version of the input (commonly when there is only one input), or a combined arrangement of the inputs (commonly in the case of multiple tiles being input). One could say that the Tile type forms a closure under these library functions.

### The `@api` macro

The `@api` macro lets Escher use a high-level DSL for defining the API for a Tile type. Think of it as defining methods for the constructors of the type with a system more powerful than plain dispatch definitions. Here is the syntax of `@api`:

```julia
@api <constructor_name> => (<TypeName>  <: Tile) begin
  <arg_specifics> # one or more
end
```

This expression generates a type whose name is `<TypeName>`, while the constructor itself will be named `<constructor_name>`. The convention in Escher is to use lower cased names for the actual constructors and CamelCased names for the types.

`<arg_specifics>` can be one of:

- `arg(x::SomeType)`
  - **it becomes:** `x::Any` in all method signatures, argument will be converted to `SomeType` before construction.
  - **what it means for the caller:** it's a normal argument. the value gets converted to the right type if it can be.
- `arg(x::SomeType=default_value)`
  - **results in** two kinds of method signatures, one with `x::Any`, argument will be converted to `SomeType` before construction; the other is without `x` in the list of arguments, the constructor then uses the default value in its place.
  - **it means** the argument is not required, if it's missing the default value is used. It's similar to Julia's trailing optional arguments, but they can appear in the beginning of an argument list too.
- `kwarg(x::SomeType=default_value)`
  - **it becomes**  `x=default_value` (kwarg) in all method definitions, argument will be converted to `SomeType`.
  - **it means** it's a regular old keyword argument. the value gets converted to the right type if it can be.
- `typedarg(x::SomeType)`:
   - **becomes** `x::SomeType` in all method signatures
   - **it means** the argument is required and must be a `SubType` instance.
- `typedarg(x::SomeType=default_value)`
   - **results in** two kinds of method signatures, one with `x::SomeType`; the other without `x` in the list of arguments, the constructor then uses the default value in its place.
- `typedkwarg(x::SomeType=default_value)`
   - **becomes** `x::SomeType=default_value` (kwarg) in all method definitions.
   - **means** a keyword argument which must be a `SomeType` instance
- `curry(x::SomeType)`
   - **results in** the creation of two kinds of methods. One which has the argument `x::SomeType` in its signature, another that does not have an argument in its place. The latter method returns a lambda that takes `x` and calls the former method to actually construct the type.
   - **means** if this argument is missing, then you get back a lambda which you can call with the missing argument. Usually only the last non-keyword argument, if any, is created with `curry`. This makes `|>` convenient to use in many cases.

For example:

```julia
@api border => (Bordered <: Tile) begin
    arg(side::Side)
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
    typedkwarg(thickness::Length=1pt)
end
```

will generate the definitions:

```julia
border(side::Any, tile::Any; color=colorant"black", thickness::Length=1pt) = Bordered(side, convert(Tile, tile), convert(Color, color), thickness)
border(side::Any; color=colorant"black", thickness::Length=1pt) = Bordered(side, tile, convert(Color, color), thickness)
```

The `tile` argument is the object that will be getting the border in this case. This is a general style in Julia, you construct new tiles to endow some property to a tile.

Let's complicate a bit more with a `typedarg`:
```julia
@api border => (Bordered <: Tile) begin
    arg(style::BorderStyle)
    typedarg(side::Array{Sides}=[left,right,top,bottom])
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
end
```

Generates:

```julia
border(style::Any, side::Array{Side}, tile::Any; color=colorant"black", thickness::Length=1pt) =
  Bordered(convert(BorderStyle, style), side, convert(Tile, tile), convert(Color, color), thickness)

border(style::Any; color=colorant"black", thickness::Length=1pt) =
  Bordered(convert(BorderStyle, style), [left,right,top,bottom], tile, convert(Color, color), thickness)

border(style::Any, side::Array{Side}; color=colorant"black", thickness::Length=1pt) =
   Bordered(convert(BorderStyle, style), side, tile, convert(Color, color), thickness)

border(style::Any; color=colorant"black", thickness::Length=1pt) =
  tile -> Bordered(convert(BorderStyle, style), [left,right,top,bottom], tile, convert(Color, color), thickness)

border(style::Any; color=colorant"black", thickness::Length=1pt) =
  tile -> Bordered(convert(BorderStyle, style), [left,right,top,bottom], tile, convert(Color, color), thickness)
```

Type parameters can be involved in `@api` definitions, for example.

```julia
@api border => (Bordered{T <: Side} <: Tile) begin
    arg(side::T)
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
end
```

TODO:
- example invocations of the generated methods
- Explanation of how javascript codebase works
