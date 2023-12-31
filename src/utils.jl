# Helper functions that may be used from here or there

# In the model, y is down, as in device space of Cairo / Luxor.
easting_to_model_x(model::ModelSpace, easting) = easting_to_model_x(model.world_to_model_scale, model.originE, easting)
easting_to_model_x(model::ModelSpace, easting::Vector) = map(x -> easting_to_model_x(model, x), easting)
easting_to_model_x(world_to_model_scale, world_units_originE, wx) = (wx - world_units_originE) / world_to_model_scale

northing_to_model_y(model::ModelSpace, northing) = northing_to_model_y(model.world_to_model_scale, model.originN, northing)
northing_to_model_y(model::ModelSpace, northing::Vector) = map(y -> northing_to_model_y(model, y), northing)
northing_to_model_y(world_to_model_scale, world_units_originN, wy) = -(wy - world_units_originN) / world_to_model_scale

model_x_to_easting(model::ModelSpace, x) = model_x_to_easting(model.world_to_model_scale, model.originE, x)
model_x_to_easting(model::ModelSpace, vx::Vector) = map(x -> model_x_to_easting(model, x), vx)
model_x_to_easting(world_to_model_scale, world_units_originE, mx) = mx * world_to_model_scale + world_units_originE

model_y_to_northing(model::ModelSpace, y) = model_y_to_northing(model.world_to_model_scale, model.originN, y)
model_y_to_northing(model::ModelSpace, vy::Vector) = map(y -> model_y_to_northing(model, y), vy)
model_y_to_northing(world_to_model_scale, world_units_originN, my) = -my * world_to_model_scale + world_units_originN


"""
    find_boolean_step_using_interval_halving(step_func::Function, lower, upper; iterations = 20, tol = 0.001)
    find_boolean_step_using_interval_halving(step_func::Function, lower, upper, iterations; tol = 0.001)
    ---> x::typeof(lower)

Find the minimum x that returns 'true'. 

`step_func(x)`       returns true 
`step_func(x - tol)` returns false 

Use this when iterating paper size (model parameters limting_height and limiting_width) to fit all labels.
For a more general function, it might be better to return the unknown midpoint between `true` and `false` values.
 
# Example
```
julia> using Logging

julia> with_logger(ConsoleLogger(stderr, Debug)) do
    find_boolean_step_using_interval_halving(1.0, 10.0) do x
        x >= π
    end
end
┌ Debug: Found root of step_func with 86 unused iterations
└ @ Main c:\\Users\\f\\.julia\\environments\\bisection\\bisection.jl:10
3.141510009765625
```
"""
function find_boolean_step_using_interval_halving(step_func::Function, lower, upper, iterations; tol = 0.001)
    mid = (lower + upper) / 2
    if iterations == 0
        @debug "Could not converge"
        return NaN
    end
    if (upper - lower) < tol
        @debug "Found root of step_func with $iterations unused iterations. tol = $tol"
        return upper
    end
    if step_func(mid)
        # Recurse into lower half
        return find_boolean_step_using_interval_halving(step_func, lower, mid, iterations - 1)
    else
        # Recurse into upper half
        return find_boolean_step_using_interval_halving(step_func, mid, upper, iterations - 1)
    end
end
function find_boolean_step_using_interval_halving(step_func::Function, lower, upper; iterations = 20, tol = 0.001)
    mid = (lower + upper) / 2
    @assert iterations > 1
    # Call the recursive method.
    x = find_boolean_step_using_interval_halving(step_func, lower, mid, iterations; tol)
    if isnan(x)
        @debug "Could not find boolean step in iterations = $iterations. `Consider parameters for find_boolean_step_using_interval_halving`"
    end
    x
end

