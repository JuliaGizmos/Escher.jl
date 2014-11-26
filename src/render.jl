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

function place(contained_elem::Elem,
               containing_elem::Elem,
               position::Position)

    containing_elem &= [:style => [:display => flex, :position => :relative]]
    contained_elem  &= [:style => [:display => flex, :position => :absolute]]
    contained_elem  &= merge(_offset(XAxis(), position),
                             _offset(YAxis(), position))

    containing_elem << contained_elem
end

padcontent(elem::Elem, len::Length) =
    elem & [ :style => [:padding => len]]

padcontent(elem::Elem, axis::YAxis, len::Length) =
    elem & [ :style => ["padding-top" => len, "padding-bottom" => len]]

padcontent(elem::Elem, axis::XAxis, len::Length) =
    elem & [ :style => ["padding-left" => len, "padding-right" => len]]

padcontent(elem::Elem, d::Direction, len::Length) =
    elem & [ :style => [string("padding-", name(d)) => len]]

pad(elem::Elem, args...) =
    padcontent(div(className="padding-box"), args...) << elem



