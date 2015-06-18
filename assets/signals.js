// IJulia setup
if (typeof(window.IPython) !== "undefined" && window) {
    window.addEventListener('polymer-ready', function () {
        var commMgr = IPython.notebook.kernel.comm_manager,
            comms = {}

        commMgr.register_target("EscherSignal", function (comm, msg) {
            comms[msg.content.data.signalId] = comm
        })

        window.addEventListener("signal-transport", function (ev) {
            console.log("all OK")
            var comm = comms[ev.detail.signalId]
            console.log("signal-transport", ev.detail)
            if (!comm) {
                console.log("Could not send message to comm, ", ev.detail)
            } else {

                console.log("sending over", comm)
                comm.send({value: ev.detail.value})
            }
        })
    })
}

