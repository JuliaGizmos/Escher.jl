
# Load custom element definitions
try
    display(MIME"text/html"(), custom_elements)
catch
end

using IJulia.CommManager
import Base.Random: UUID, uuid4

function setup_transport(sig::Input)
    id = makeid(sig)
    comm = Comm(:CanvasSignal, data=[:signalId => id])
    comm.on_msg = (msg) -> push!(sig, decodeJSON(sig, msg.content["data"]["value"]))
    return id
end

