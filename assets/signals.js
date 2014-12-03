// IJulia setup
if (IPython && window) {
    window.addEventListener('polymer-ready', function () {
        var commMgr = IPython.notebook.kernel.comm_manager,
            comms = {}
        window.addEventListener("signal-setup", function (ev) {
            comms[ev.detail.signalId] =
                commMgr.new_comm("canvas_to_jl", {"signalId": ev.detail.signalId})
        })

        window.addEventListener("signal-updated", function (ev) {
            var comm = comms[ev.detail.signalId]
            console.log("signal-updated", ev.detail)
            if (!comm) {
                console.log("Could not send message to comm, ", ev.detail)
            } else {
                comm.send(ev.detail.value)
            }
        })
    })
}

