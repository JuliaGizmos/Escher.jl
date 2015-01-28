export render

# style helpers
style(elem::Elem, key, val)  = elem & [:style => [key => val]]

# render function takes a tile and creates an Elem

render(x::Elem) = x
render(x::Leaf) = x.element

########## Layouts ##########

render(t::Empty) = div(style=[:display => :inherit, :position => :inherit])

# 0. height and width
render(t::Width) = render(t.tile) & [:style => [:width => t.w]]
render(t::Height) = render(t.tile) & [:style => [:height => t.h]]

# 1. Positioning

render(p::TopLeft, x, y) =
    [:top => y, :left => x]
render(p::MidTop, x, y) =
    [:left =>  50cent, :top => y, :transform => "translate(-50%)", :marginLeft => x]
render(p::TopRight, x, y) =
    [:top => x, :right => y]
render(p::MidLeft, x, y) =
    [:top => 50cent, :marginTop => y, :left => x, :transform => "translate(0, -50%)"]
render(p::Middle, x, y) =
    [:top => 50cent, :left=>50cent, :marginLeft => x, :marginTop => y, :transform => "translate(-50%, -50%)"]
render(p::MidRight, x, y) =
    [:top => 50cent, :transform => "translate(0, -50%)", :marginTop => y, :right => x]
render(p::BottomLeft, x, y) =
    [:bottom => y, :left => x]
render(p::MidBottom, x, y) =
    [:left => 50cent, :marginLeft => x, :bottom => y, :transform => "translate(-50%)"]
render(p::BottomRight, x, y) =
    [:bottom => y, :right => x]

render(c::Corner) = [:style => render(c, 0, 0)]
render{C <: Corner}(p::Relative{C}) = [:style => render(C(), p.x, p.y)]

function render(tile::Positioned)
    outer = render(tile.containing)
    inner = render(tile.contained)

    outer &= [:style => [:position => :relative]]
    inner &= [:style => [:position => :absolute]]

    outer << (inner & render(tile.position))
end

# 2. Flow

render(t::Grow) =
    render(t.tile) & [:style => [:flexGrow => t.factor]]

render(t::Shrink) =
    render(t.tile) & [:style => [:flexShrink => t.factor]]

render(t::FlexBasis) =
    render(t.tile) & [:style => [:flexBasis => t.basis]]

classes(f::Flow{Right}) =
    "flow flow-right"

classes(f::Flow{Left}) =
    "flow flow-left"

classes(f::Flow{Down}) =
    "flow flow-down"

classes(f::Flow{Up}) =
    "flow flow-up"

classes(f::Wrap{Down, Right}) =
    "flex-wrap"

classes(f::Wrap{Up, Right}) =
    "flex-wrap-reverse"

classes(f::Wrap{Down, Left}) =
    "flex-wrap"

classes(f::Wrap{Up, Left}) =
    "flex-wrap-reverse"

classes(f::Wrap{Left, Up}) =
    "flex-wrap-reverse"

classes(f::Wrap{Right, Up}) =
    "flex-wrap-reverse"

classes(f::Wrap{Left, Down}) =
    "flex-wrap"

classes(f::Wrap{Right, Down}) =
    "flex-wrap"

# Packing
classes(t::PackedItems{AxisStart}) =
    "pack-start"

classes(t::PackedItems{AxisEnd}) =
    "pack-end"

classes(t::PackedItems{AxisCenter}) =
    "pack-center"

classes(t::PackedItems{SpaceBetween}) =
    "pack-space-between"

classes(t::PackedItems{SpaceAround}) =
    "pack-space-around"

classes(t::PackedLines{AxisStart}) =
    "pack-lines-start"

classes(t::PackedLines{AxisEnd}) =
    "pack-lines-end"

classes(t::PackedLines{AxisCenter}) =
    "pack-lines-center"

classes(t::PackedLines{Stretch}) =
    "pack-lines-stretch"

classes(t::PackedLines{SpaceBetween}) =
    "pack-lines-space-between"

classes(t::PackedLines{SpaceAround}) =
    "pack-lines-space-around"

classes(t::PackedAcross{AxisStart}) =
    "pack-across-start"

classes(t::PackedAcross{AxisEnd}) =
    "pack-across-end"

classes(t::PackedAcross{AxisCenter}) =
    "pack-across-center"

classes(t::PackedAcross{Stretch}) =
    "pack-across-stretch"

classes(t::PackedAcross{Baseline}) =
    "pack-across-baseline"

render(f::Flow) =
    Elem(:div, map(render, f.tiles)) & [:className => classes(f)]

render(f::FlexContainer) =
    render(f.tile) & [:className => classes(f.tile) * " " * classes(f)]

render(t::FlexSpace{Right}) =
    render(t.tile) & [:style => ["marginRight" => :auto]]

render(t::FlexSpace{Left}) =
    render(t.tile) & [:style => ["marginLeft" => :auto]]

render(t::FlexSpace{Down}) =
    render(t.tile) & [:style => ["marginBottom" => :auto]]

render(t::FlexSpace{Up}) =
    render(t.tile) & [:style => ["marginTop" => :auto]]


# 4. padding

render(cont::Container) = div(render(cont.tile),
                          style=[:height => :auto, :width => :auto])

render_style(pad::Padded{Nothing}) =
    [:padding => pad.len]
render_style(pad::Padded{Horizontal}) =
    [:paddingRight => pad.len, :paddingLeft => pad.len]
render_style(pad::Padded{Vertical}) =
    [:paddingTop => pad.len, :paddingBottom => pad.len]
render_style(pad::Padded{Vertical}) =
    [:paddingTop => pad.len, :paddingBottom => pad.len]
render_style(pad::Padded{Up}) =
    [:paddingTop => pad.len]
render_style(pad::Padded{Down}) =
    [:paddingBottom => pad.len]

render(padded::Padded) =
    render(padded.tile) & [:style => render_style(padded)]

render(t::StateSignal) =
    render(t.tile) << Elem("state-signal",
        attributes=[:name=>t.name, :attr=>t.attr, :trigger=>t.trigger])

render(tile::StopPropagation) =
    Elem("stop-propagation", render(tile.tile),
        attributes=[:name=>tile.name])

function render(sig::InboundSignal)
    id = setup_transport(sig.signal)
    Elem("signal-transport",
        render(sig.tile), attributes=[:name=>sig.name, :signalId => id])
end

### Widgets

custom(name, attrs) = Elem(name, attributes=Dict(attrs))
custom(name; attrs...) = Elem(name, attributes=Dict(attrs))

_bool(a, name) = a ? name : nothing

render(s::Slider) =
    custom("paper-slider", min=first(s.range), max=last(s.range), id=s.tag,
           step=step(s.range), value=s.value, editable=s.editable,
           disabled=s.disabled, secondaryProgress=s.secondaryprogress)

render(c::BoolWidget{:checkbox}) =
    custom("paper-checkbox", checked=c.value, id=c.tag, disabled=_bool(c.disabled, "disabled"))

render(t::BoolWidget{:toggle}) =
    custom("paper-toggle-button",
           checked=t.value,
           id=t.tag,
           disabled=_bool(t.disabled, "disabled"))

render(t::TextInput) =
    custom("paper-input") &
           [ :id=>t.tag, :label=>t.label,
             :floatingLabel=>_bool(t.floatinglabel, "floatingLabel"), :disabled=>_bool(t.disabled, "disabled")]

render(t::SelectionItem) =
    custom("paper-item", value=t.value) << render(t.tile)

render(d::Dropdown) =
    custom("paper-dropdown-menu",
           id=d.tag,
           value=d.value,
           label=d.label,
           floatingLabel=_bool(d.floatinglabel, "floatingLabel"),
           disabled=_bool(d.disabled, "disabled")) |>
    (wrap -> reduce(<<, wrap, map(render, d.items)))

render(l::Label) =
    custom("core-label"; [:for => l.target]...) << render(l.label)
