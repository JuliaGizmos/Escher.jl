#----------------------------------------------------------------------
# Boids algorithm visualization
# Based on pseudocode at http://www.kfish.org/boids/pseudocode.html
# Simulate flocking birds using simple rules.
# Initial version developed and contributed by Iain Dunning (@IainNZ)
# as part of the JuliaCon 2015 workshop
# TODO:
# - Add interactivity for parameters that govern behavior.
# - Add a force that attracts to mouse pointer.
#----------------------------------------------------------------------

using Compose
using Colors

#----------------------------------------------------------------------

immutable Boid
    pos::Vector{Float64}
    vel::Vector{Float64}
end
# Create new boid at random location and velocity
Boid() = Boid(rand(2),rand(2)/1000)
function draw(b::Boid)
    (context(),
        (context(),circle(b.pos[1]+b.vel[1],b.pos[2]+b.vel[2],0.005),fill(colorant"red")),
        (context(),circle(b.pos[1],b.pos[2],0.01),fill(colorant"blue"))
    )
end

#----------------------------------------------------------------------

function main(window)
    # Run at 60 FPS
    eventloop = every(1/30)

    # Create population of boids
    boids = [Boid() for i in 1:50]

    map(eventloop) do _
        # Force 1: Attract to center
        boid_center = mapreduce(b->b.pos, +, boids)/length(boids)
        for boid in boids
            boid.vel[:] += (boid_center - boid.pos)/600
        end

        # Force 2: Avoid others
        for boid in boids
            avoid = zeros(2)
            for other_boid in boids
                boid == other_boid && continue
                if norm(boid.pos - other_boid.pos) <= 0.2
                    avoid -= other_boid.pos - boid.pos
                end
            end
            boid.vel[:] += avoid/1000
        end

        # Force 3: Match velocities with nearby
        for boid in boids
            perceived_vel = zeros(2)
            for other_boid in boids
                boid == other_boid && continue
                perceived_vel += other_boid.vel
            end
            perceived_vel /= length(boids)-1
            boid.vel[:] += (perceived_vel - boid.vel)/900
        end

        # Limit max velocity
        MAXVEL = 0.5
        for boid in boids
            absvel = norm(boid.vel)
            if absvel >= MAXVEL
                boid.vel /= absvel*MAXVEL
            end
        end

        # Update positions
        for boid in boids
            boid.pos[:] += boid.vel
        end

        # Determine bounding box
        minx = mapreduce(b->b.pos[1], min, boids)
        maxx = mapreduce(b->b.pos[1], max, boids)
        miny = mapreduce(b->b.pos[2], min, boids)
        maxy = mapreduce(b->b.pos[2], max, boids)
        vbox(
            title(3, "EscherBoids"),
            vskip(1em),
            compose(context(units=UnitBox(-0.5,-0.5,2,2)),
                # Uncomment for bounding box of plot to track boids
                #context(units=UnitBox(minx,miny,maxx-minx,maxy-miny)),
                [draw(boid) for boid in boids]...)
            ) |> packacross(center)
    end
end
