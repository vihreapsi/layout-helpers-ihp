module IHPQSLib
  module Utils
    extend self

    def drect_nm(cell,x, y, w, h, layer)
      cell.shapes(layer).insert(RBA::DBox.new(x.to_f/1000,y.to_f/1000,(x+w).to_f/1000,(y+h).to_f/1000))
    end

    # The _fitter_ computes coordinates of equally sized and equally spaced lines
    # within a given length line. It follows strict grid snapping and be constrained
    # to a minimum spacing.
    # +size+:: the length of the equally spaced lines
    # +length+:: the length of the container
    # +min_spacing+:: the minimum spacing constraint
    # +snap_grid+:: 
    def fitter_nm(size, length, min_spacing, snap_grid)
     
    end
  end
end

