# Canvas: A language for layouts

> One cause of the CSS mess is the eschewing of elegant, flexible abstractions for “1000 special cases,” a detrimental approach which precludes simplicity and generality in any domain. However, the larger and more germane fault is the language’s attempt to serve as both tool and platform, thereby succeeding as neither.

A good platform is

* **Simple**: so that implementations can have parity
* **General**: so that *all* of the medium's capabilities can be expressed in terms of the platform's grammar.

What would a language for specifying layouts?

## Starting from first principles

Let us now consider the premises in which we operate.

* *Surface*: surface is an unbounded 2D plane on which we define a cartesian coordinate system:
    * The origin is at the top-left corner of the screen. Rightward is +x axis, downward is -y axis.
    * We assume there are means to convert length units to pixel units and paint the intended pictures, hence we deal with length as an abstract quantity of any unit from here on.
* *Element*: an `element` is a rectangular region which can be *placed* on top of or behind another element.
* *Page*: a `page` is an `element` whose width is the same as that of the display, and whose height can be infinite.

In light of these premises, our quest can begin by asking:

* What is the smallest set of rules using which one can arrange boxes in all possible ways?

## The smallest set of rules

1. Every element's height and width can either be specified or infered. Specifically, we assume the existence of `width(elem::Element)` and the `height(elem::Element)` functions which give us the width and height of `elem`.
2. An element can be drawn with its top-left corner at any point on the surface.

## Towards a rich language

These two lower level primitives are tedious to deal with, and they must best be thought of as the assembly language for our tool. Below I list out functions that will be of more help in doing mundane placement and juxtaposition duties. I defer to the code for the complete implementations of these functions.

We will now visit the question "How would a user want to arrange boxes?" In doing so we build a series of functions and delimate them with abstraction boundaries[SICP Chapter 1]. Functions within a boundary will only use functions above their upper boundary in their own implementation.

### Placement

The `place` function places an element relative to another starting at a given `x`, `y`, `z` offsets.

```julia
immutable Offset
    x_offset::Length
    y_offset::Length
    z_offset::Length
end

place(contained_elem::Element, containing_elem::Element, position::Offset) # :: Element
```

---- boundary ----

### Juxtaposition

The `flow` function places a vector of elements one after the other (with no space between them) in one of the six directions: down, up, right, left, inward or outward.

```julia

abstract Axis

immutable X <: Axis end
immutable Y <: Axis end
immutable Z <: Axis end

immutable Direction{T <: Axis, direction}
end

const right   = Direction{X, +1}()
const left    = Direction{X, -1}()
const up      = Direction{Y, +1}()
const down    = Direction{Y, -1}()
const inward  = Direction{Z, -1}()
const outward = Direction{Z, +1}()

flow(direction::Direction, elements::Vector{Element}) # :: Element
```

Note: positioning and flow are the two primitives [Elm](http://library.elm-lang.org/catalog/elm-lang-Elm/0.13/Graphics-Element) provides via the `container` and `flow` functions.

### Embellishments: padding, margin

Padding and margin are essentially placement operations. To pad an element, you place *its contents* inside a new element called the "padding box". Similarly to provide a margin to an element, you place it inside a "margin box" which again is just another element!

```julia
pad(elem::Element, padding::Length) # :: Element
pad(elem::Element, direction::Direction, padding::Length) # :: Element

margin(elem::Element, padding::Length) # :: Element
margin(elem::Element, direction::Direction, padding::Length) # :: Element
```

Note that an implmenetation using CSS's padding and margin properties would fail to acheive parity with this implementation in that padding and margins can be appled successively to a given element without overwriting the previously applied padding and margin. This approach also wonderfully sidestep's one of CSS's abominable bad-habits: special casing the margin property in different contexts.

### Intersperse empty space

Given a vector of elements, `intersperse` returns a vector of the same size with each element placed inside a container such that when the vecor is `flowed` in the given direction, the elements will have the specified space between them. (TODO: Explain this better)

```julia
intersperse(elems::Vector{Element}, along::Axis, length::Length) # :: Vector{Element}
intersperse(elems::Vector{Element}, along::Axis, lengths::Vector{Length}) # :: Vector{Element}
```

The second form of intersperse takes n-1 lengths along with a vector of n elements and intersperses the lengths between the elements.

### Flexing

Given a vector of elements, `flex` optionally takes a vector of numbers denoting the fraction of the container's dimension in the given direction that the element should be stretched to.

```julia
flex(parent::Element, elems::Vector{Element}, along::Axis) # :: Vector{Element}
flex(parent::Element, elems::Vector{Element}, along::Axis, lengths::Vector{Float64}) # :: Vector{Element}
```

The first form evenly distributes them, the second one uses a vector of fractions to decide the distribution.

---- boundary ----

### Distributing empty space

The `distribute_space` function builds on `intersperse` and the parent's `width` and `height` to distribute remaining within parent element between the vector of elements.

```julia
distribute_space(parent::Element, elems::Vector{Element}, direction::Direction) # :: Vector{Element}
distribute_space(parent::Element, elems::Vector{Element}, direction::Direction, Lengths::Vector{Float64}) # :: Vector{Element}
```

### Centering

```julia
center(element::Element, axis::Axis)
```

### Wrapping

```julia
wrap(parent::Element, elems::Vector{Elements}, wrap_direction::Direction) # :: Element
```

Note that the wrapping function will need to reflect on the dimensions of the parent and then decide how many of the elements should appear in each row or column

## Offloading rendering to the browser: flexbox as a platform

The problem of responding to change in page width requires more consideration:

* Given a page width, we would like a function which produces a new layout for that page width
  - f<sub>layout</sub>(w<sub>page</sub>) = layout

But we are operating under the contract that only Julia code is allowed to modify the DOM. Which means that the function f will have to be in Julia, and the Julia programmer needs to explicitly take into account the width of the page while designing layouts.

This seems reasonable and should be exposed for the user to use if he so wishes. We will discuss how the user can access the current width of the page in the Signals section below.

But this can become quickly tedious.

With the new CSS flexboxes I am hoping we can get an implementation with perfect parity to the system defined above, without having to watch for page width changes.
