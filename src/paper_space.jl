"""
    snap_with_labels(m::ModelSpace; 
        plot_guides = false, 
        draw_grid = true, 
        plot_overlapping = false, 
        leaderline = true, 
        halign = :left, 
        offsetbelow = true,
        offset = Point((-1.5, 2.0) .* m.EM, 
        kwds...)
    --> png image for display. Outputs and svg and a png file. Using `LuxorLayout.snap`

See `LabelPaperSpace` regarding keywords, for example by modifiying `offset` values.

# Example, iterating to find a good plot size for a map.
```
```


"""
function snap_with_labels(m::ModelSpace; 
        plot_guides = false, 
        draw_grid = true, 
        plot_overlapping = false,
        kwds...)
    draw_grid && draw_utm_grid(m)
    if length(m.labels) == 0
        @info "No labels in model."
        return snap()
    end
    labels_ps = labels_paper_space_from_model_and_keywords(m; kwds...)
    # Now optimize the offset positions of paper space labels:
    LuxorLabels.optimize_offset_direction_diagonal!(labels_ps, plot_label_bounding_box)
    if plot_overlapping
        # Define a function that is executed on another thread, 
        # in the context of an svg overlay picture, then on a png overlay picture.
        f = () -> label_all_at_given_offset(;labels = labels_ps, plot_guides)
    else
        # This would unnecessarily re-run the prioritization algorithm - once for 
        # png output and once for svg output.
        #f = () -> label_prioritized_at_given_offset(;labels = labels_ps, plot_guides)
        #
        # Instead, we run the prioritization from here:
        prioritized_indexes, boundary_boxes = indexes_and_bbs_prioritized_at_given_offset(;labels = labels_ps)
        # ...So we don't have to later on.
        dropped_indexes = setdiff(1:length(labels_ps), prioritized_indexes)
        if length(dropped_indexes) < 4
            msg = join(map(l -> string(l), labels_ps[dropped_indexes]), "\n")
        else
            msg = join(map(l -> string(l), dropped_indexes), ", ")
        end
        if length(dropped_indexes) > 0
            @info "LuxorLabels drops $(length(dropped_indexes)) labels: $msg"
        end
        # Define a function that is executed on another thread, 
        # in the context of an svg overlay picture, then on a png overlay picture.
        f = () -> label_all_at_given_offset(;labels = collect(labels_ps[prioritized_indexes]), plot_guides)
    end
    snap(f)
end

"""
    labels_paper_space_from_model_and_keywords(m::ModelSpace; 
        kwds...)
    ---> Vector{LuxorLabels.LabelPaperSpace}

See `LuxorLabels.LabelPaperSpace` regarding keywords, for example `offset`. For specifying single labels, 
give keyword values as vectors.
"""
function labels_paper_space_from_model_and_keywords(m::ModelSpace; 
    kwds...)
    #
    if length(m.labels) == 0
        throw("No labels in model.")
    end
    # These parameters are collected from the active drawing.
    # They rely on something having been drawn already.
    model_to_paper_scale = scale_limiting_get()
    model_bb = inkextent_user_with_margin()
    # Filter labels within model_bb. Adapt this later for a crop box?
    visible_labels = filter(m.labels) do l
        Point(l.x, l.y) ∈ model_bb
    end
    # Extract further paper label details from model settings.
    labels_paper_space_from_labels_and_keywords(visible_labels; 
        fontsize_prominence_1 = m.FS, 
        shadowcolor = m.colorscheme[9], 
        textcolor = m.colorscheme[1],
        model_to_paper_scale, 
        O_model_in_paper_space = midpoint(O - model_bb) * model_to_paper_scale, 
        kwds...)
end



"""
    labels_paper_space_from_labels_and_keywords(ms_labels::Vector{LabelModelSpace};
        O_model_in_paper_space = O,
        model_to_paper_scale = 1.0,
        kwds...)
    ---> Vector{LuxorLabels.LabelPaperSpace}

See `LuxorLabels.LabelPaperSpace` regarding keywords, for example `offset`. For specifying single labels, 
give keyword values as vectors.
"""
function labels_paper_space_from_labels_and_keywords(ms_labels::Vector{LabelModelSpace};
    O_model_in_paper_space = O,
    model_to_paper_scale = 1.0,
    kwds...)
   # Extract parameters from model space labels
   txt = map(l -> l.text, ms_labels)
   prominence = map(l -> l.prominence, ms_labels)
   x = map(l -> l.x * model_to_paper_scale - O_model_in_paper_space.x, ms_labels)
   y = map(l -> l.y * model_to_paper_scale - O_model_in_paper_space.y, ms_labels)
   # Add keyword details to produce the more detailed PaperSpace labels.
   LuxorLabels.labels_paper_space(;txt, prominence, x, y, kwds...)
end
