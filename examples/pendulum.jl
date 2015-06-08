using Gadfly

g = 9.807 # m/s^2

τ = 2*pi
δt = 0.03

type Pendulum
    θ :: Real
    ω :: Real
end

# Euler integration (unused)
function Δ(s::Pendulum,δt,τ) # s is for system
    θ=s.θ+s.ω*δt
    ω=s.ω+τ(s)*δt
    return Pendulum(θ,ω)
end

function midpoint_step ( s , dt :: Real, τ)
    ω_half = s.ω + 0.5*dt*τ(s)
    θ_half = s.θ + 0.5*dt*s.ω 
    θ      = s.θ + dt*ω_half
    ω      = s.ω + dt*τ(Pendulum(θ_half,ω_half))
    return θ, ω
end

acc(s) = -g/1*sin(s.θ)

function step(s,δt,acc)
    th, w = midpoint_step(s,δt,acc)
    return Pendulum(th, w)
end

s0 = Pendulum(τ/4-0.4, 4.000)

function main(window)
    push!(window.assets, "widgets")

    fps10 = fpswhen(25, window.alive) # lies
    
    sᵗ = foldl( (s, dt) -> step(s, dt, acc), s0, fps10) 
    lift(sᵗ) do s
	vbox(h1("(not very) Interactive Pendulum"),
	    string(s),
            #plot(x=[s.θ, 2pi, -2pi], y=[s.ω, 2pi, -2pi], Geom.point, Guide.XLabel("angle"), Guide.YLabel("angular velocity")) 
        )
    end
end
