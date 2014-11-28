export render

# render function takes a tile and creates an Elem

render(x::Elem) = x
render(x::Leaf) = x.element

########## Layouts ##########

# 1. Placed
_offset(axis::XAxis, position::Relative{Corner{-1}}) =
    [:left => position.x]
_offset(axis::XAxis, position::Relative{Corner{1}}) =
    [:right => position.x]
_offset{X}(axis::YAxis, position::Relative{Corner{X, 1}}) =
    [:top => position.y]
_offset{X}(axis::YAxis, position::Relative{Corner{X, -1}}) =
    [:bottom => position.y]
_offset(axis::XAxis, position::Corner{-1}) =
    [:left => 0]
_offset(axis::XAxis, position::Corner{1}) =
    [:right => 0]
_offset{X}(axis::YAxis, position::Corner{X, 1}) =
    [:top => 0]
_offset{X}(axis::YAxis, position::Corner{X, -1}) =
    [:bottom => 0]

function render(tile::Positioned)
    outer = render(tile.containing_elem) & [:style => [:position => :relative]]
    inner = render(tile.contained_elem)
    style = merge(merge(_offset(XAxis(), el.position),
                               _offset(YAxis(), el.position)),
                        [:position => :absolute])
    outer << (inner & style)
end

# 2. Flow

_layout(flow::Flow{Right, Nothing}) =
    # FIXME: horizontal is right-to-left for arabic e.g.
    boolattr([:layout, :horizontal])

_layout(flow::Flow{Left, Nothing}) =
    boolattr([:layout, :horizontal, :reverse])

_layout(flow::Flow{Right, Down}) =
    boolattr([:layout, :horizontal, :wrap])

_layout(flow::Flow{Right, Up}) =
    boolattr([:layout, :horizontal, "wrap-reverse"])

_layout(flow::Flow{Left, Down}) =
    boolattr([:layout, :horizontal, :reverse, :wrap])

_layout(flow::Flow{Left, Up}) =
    boolattr([:layout, :horizontal, :reverse, "wrap-reverse"])

_layout(flow::Flow{Down, Nothing}) =
    boolattr([:layout, :vertical])

_layout(flow::Flow{Up, Nothing}) =
    boolattr([:layout, :vertical, :reverse])

_layout(flow::Flow{Down, Right}) =
    boolattr([:layout, :vertical, :wrap])

_layout(flow::Flow{Down, Right}) =
    boolattr([:layout, :vertical, "wrap-reverse"])

_layout(flow::Flow{Up, Right}) =
    boolattr([:layout, :vertical, :reverse, :wrap])

_layout(flow::Flow{Up, Left}) =
    boolattr([:layout, :vertical, :reverse, "wrap-reverse"])

render(flow::Flow) = div(map(render, flow.tiles)) & _layout(flow)

# 3. Flexed and Alignment

render(flex::Flexed) =
    render(flex.tile) &
        [:style =>
            [:MsFlux => flex.factor,
             :WebkitFlux => flex.factor,
             :flex => flex.factor]] #TODO: Make a custom element for this

# 4. padding

render(wrap::Wrap) = div(render(wrap.tile),
                          style=[:display => :inherit, :position => :inherit])

_padding(pad::Padded{Nothing}) =
    [:padding => pad.len]
_padding(pad::Padded{XAxis}) =
    [:paddingRight => pad.len, :paddingLeft => pad.len]
_padding(pad::Padded{YAxis}) =
    [:paddingTop => pad.len, :paddingBottom => pad.len]
_padding(pad::Padded{YAxis}) =
    [:paddingTop => pad.len, :paddingBottom => pad.len]
_padding(pad::Padded{Up}) =
    [:paddingTop => pad.len]
_padding(pad::Padded{Down}) =
    [:paddingBottom => pad.len]

render(padded) =
    render(padded.tile) & [:style => _padding(padded)]
