using Dates
using Gadfly
using Markdown

# The types here are mainly copied from https://github.com/SavinaRoja/maths/blob/master/Introduction%20to%20PID%20Controllers.ipynb, 
# the variable, methods, and semantics are mostly preserved so one can more easily compare Python to Julia, though this may change in a future update

type PIDController
    kp :: Real
    ki :: Real
    kd :: Real
    setpoint::Real
    err_sum :: Real
    latest_err :: Real
    latest_time :: Real
    p_term :: Real
    i_term :: Real
    d_term :: Real
    
    #alternate constructors so we don't have to define everything every time
    PIDController(p,i,d,s)= new(p,i,d,s,0.,0.,time(),0.,0.,0.)
    PIDController(p,i,d)= new(p,i,d,1.,0.,0.,time(),0.,0.,0.)
end

# let time_del = (time() - pidc.latest_time, state) if not using Reactive
function update(self,time_del,state)
    err = self.setpoint - state
    self.err_sum += err
    d_err = (err - (self.latest_err)) / time_del
    err = self.setpoint - state
    self.err_sum += err
    d_err = (err - self.latest_err) / time_del

    self.p_term = self.kp * err
    self.i_term = self.ki * self.err_sum
    self.d_term = self.kd * d_err

    output = self.p_term + self.i_term + self.d_term

    self.latest_time += time_del
    self.latest_err = err

    return output
end

# this may be deprecated when I switch to immutable types
function retune(pid,kp,ki,kd)
    if kp != None; pid.kp = float(kp); end
    if ki != None; pid.ki = float(ki); end
    if kd != None; pid.kd = float(kd); end
end

function pid_simulate(p,i,d, setpoints, init_state, perturbation)
    if perturbation==None
        perturbation = (state, setp_val, p, i, d) -> 0.0
    end
    if init_state == None
        state = 0.0
    else
        state = float(init_state)
    end
    
    pid = PIDController(p, i, d)
    
    states = Float64[]
    outputs = Float64[]
    p_terms = Float64[]
    i_terms = Float64[]
    d_terms = Float64[]
    errors = Float64[]
    perturbances = Float64[]
    
    for setp_val in setpoints
        push!(states,state)
        pid.setpoint = setp_val
        
        output = update(pid, time() - pid.latest_time, state)
        perturbance = perturbation(state, setp_val, p, i, d)
        state += output + perturbance
        
        push!(errors,pid.latest_err)
        push!(p_terms,pid.p_term)
        push!(i_terms,pid.i_term)
        push!(d_terms,pid.d_term)
        push!(outputs,output)
        push!(perturbances,perturbance)
    end
    
    ticks = range(0,length(setpoints))
    
    tvars = ["state"=> states,
             "output"=> outputs,
             "error"=> errors,
             "p"=> p_terms,
             "i"=> i_terms,
             "d"=> d_terms,
             "perturbance"=> perturbances,
             "setpoint"=> setpoints]
    return ticks, tvars
end

selectsetpoint = {
    1 => hcat([linspace(1,10,50),
	linspace(1,10,50),
	linspace(10,1,50),
	linspace(1,20,50)]),
    2 => hcat([linspace(0,0,20),linspace(20,20,180)]),
    3 => map(x->20*sin(x),linspace(0,4pi,200))}
 

kpt = Input(0.2)
kit = Input(0.1)
kdt = Input(0.00000001)
spft = Input(1)

perturb = (state, setp_val, p, i, d) -> 0.0

x_axis0, results = pid_simulate(0.2, 0.1, 0.00000001, selectsetpoint[1], 5.0, perturb)

x_axis = [x for x in x_axis0] # LazyList -> Array

function main(window)
    #push!(window.assets, "layout2")
    push!(window.assets, "widgets")
    push!(window.assets, "tex")

    lift(kpt, kit, kdt, spft ) do kp, ki, kd, spf
        _, results = pid_simulate(kp, ki, kd, selectsetpoint[spf], 5.0, perturb)
        vbox(h1("PID Controller"),
            "The equation for the PID",
            tex("u(t) = K_{P} \\cdot e(t) + K_{I} \\cdot \\int e(t)dt + K_{D} \\cdot \\frac{d}{dt} e(t)"),
            hbox("where ",tex("K_P"), " is the proportional term, ", tex("K_I")," is the integral term, and ",tex("K_D")," is the derivative term."),
            hbox(tex("e(t)"), " is the error at time t, ", tex("u(t)")," is the output signal"),
            md"Try tuning it via the [Ziegler-Nichols method](https://en.wikipedia.org/wiki/Ziegler%E2%80%93Nichols_method)",
            md"Usually, the setpoint function isn't deterministic",
            #hbox("setpoint function (broken, do not touch)", dropdownmenu("impulse",["sawtoothlike","impulse","sin"]) >>> spft),
            hbox("setpoint function", slider(1:3)  >>> spft),
            hbox("proportional term", slider(0:.01:1.5) >>> kpt) |> packacross(center),
            hbox("integral term", slider(0:.01:0.2) >>> kit) |> packacross(center),
            hbox("derivative term", slider(0:.0000001:0.00001) >>> kdt) |> packacross(center),
            hbox( "DEBUG  spf ::", string(typeof(spf)), " = ", string(spf)),
            "The state of the system",
            plot(x=x_axis,y=results["state"],Geom.line)  |> pad(2em),
            "P,I,D -> R,G,B",
##            plot(x=x_axis,y=results["p"], Geom.line, Theme(default_color=color("red")))  |> pad(2em),
	    plot(
		layer(x=x_axis,y=results["p"],Geom.line,Theme(default_color=color("red"))),
		layer(x=x_axis,y=results["i"],Geom.line,Theme(default_color=color("green"))),
		layer(x=x_axis,y=results["d"],Geom.line,Theme(default_color=color("blue")))
		) |> pad(2em),
	)
    end
end
