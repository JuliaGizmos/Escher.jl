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
    [:left =>  50pc, :top => y, :transform => "translate(-50%)", :marginLeft => x]
render(p::TopRight, x, y) =
    [:top => x, :right => y]
render(p::MidLeft, x, y) =
    [:top => 50pc, :marginTop => y, :left => x, :transform => "translate(0, -50%)"]
render(p::Middle, x, y) =
    [:top => 50pc, :left=>50pc, :marginLeft => x, :marginTop => y, :transform => "translate(-50%, -50%)"]
render(p::MidRight, x, y) =
    [:top => 50pc, :transform => "translate(0, -50%)", :marginTop => y, :right => x]
render(p::BottomLeft, x, y) =
    [:bottom => y, :left => x]
render(p::MidBottom, x, y) =
    [:left => 50pc, :marginLeft => x, :bottom => y, :transform => "translate(-50%)"]
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

render_style(f::Flow{Right}) =
    [:style => [:flexDirection => :row,
                :display=>:flex]]

render_style(f::Wrap{Down, Right}) =
    [:style => [:flexWrap => :wrap,
                :alignContent => "flex-start"]]

render(f::Flow) =
    Elem(:div, map(render, f.tiles)) & render_style(f)

render(f::Wrap) =
    render(f.tile) & render_style(f)
# 4. padding

render(wrap::Container) = div(render(wrap.tile),
                          style=[:display => :inherit, :position => :inherit])

_padding(pad::Padded{Nothing}) =
    [:padding => pad.len]
_padding(pad::Padded{Horizontal}) =
    [:paddingRight => pad.len, :paddingLeft => pad.len]
_padding(pad::Padded{Vertical}) =
    [:paddingTop => pad.len, :paddingBottom => pad.len]
_padding(pad::Padded{Vertical}) =
    [:paddingTop => pad.len, :paddingBottom => pad.len]
_padding(pad::Padded{Up}) =
    [:paddingTop => pad.len]
_padding(pad::Padded{Down}) =
    [:paddingBottom => pad.len]

render(padded::Padded) =
    render(padded.tile) & [:style => _padding(padded)]

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
