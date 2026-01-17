module IHPQSLib
  module Utils
    extend self

    # _drect_ draws a rectangle in nanometers on a specific layer
    # +cell+:: is the cell on which the rectangle will be drawn
    # +x+:: is x coordinates of the recangle
    # +y+:: is y coordinates of the recangle
    # +w+:: is the width of the recangle
    # +h+:: is the height of the recangle
    def drect(cell,x, y, w, h, layer)
      cell.shapes(layer).insert(RBA::DBox.new(x.to_f/1000,y.to_f/1000,(x+w).to_f/1000,(y+h).to_f/1000))
    end

    # The _fitter_ computes in nanometer coordinates of equally sized and equally spaced lines (_sprinkles_)
    # within a given length line. It follows strict grid snapping and be constrained
    # to a minimum spacing.
    # +size+:: the length of the sprinkles
    # +length+:: the length of the sprinkle container
    # +min_spacing+:: the minimum spacing constraint
    # +position+:: extra space position:
    # * l:: left (default)
    # * r:: right
    # * c:: center
    # +snap_grid+:: the grid constraint snapping
    # +paddings+:: consider a padding at start and end of the sprinkle container
    def fitter(size, length, min_spacing, position="l", snap_grid=5, paddings=0)
      ## Argument validation
      # size fitting on length + paddings
      raise ArgumentError, "Size of one sprinkle can't fit in length" if length - (paddings * 2) < size

      # size respects snap grid
      raise ArgumentError, "Size isn't on snap grid" if snap_grid > 0 && size % snap_grid != 0
      
      # length respects snap grid
      raise ArgumentError, "Length isn't on snap grid" if snap_grid > 0 && length % snap_grid != 0
      
      # min_spacing respects snap grid
      raise ArgumentError, "Min. Spacing isn't on snap grid" if snap_grid > 0 && min_spacing % snap_grid != 0
      
      ## Computing
      # Effective length
      l = length - (paddings * 2)
      
      # Number of sprinkles
      sprinkle_number = ((l - size) / (size + min_spacing)) + 1

      # Remaining space
      rs = (l - size) % (size + min_spacing)
      puts "Remaining space: #{rs}"

      # Final spacing
      if rs % (sprinkle_number-1) > 0
        spacing = min_spacing + (rs / (sprinkle_number-1))
      else
        spacing = min_spacing
      end

      puts "Spacing => #{spacing}"

      # Extra space
      extra_space = (l - size) % (size + spacing)

      # Extra space position
      extra_space_idx = case position
                        when "c" then sprinkle_number/2
                        when "r" then (sprinkle_number-1)
                        else 1
                        end

      ## Coordinates computing
      Array.new(sprinkle_number) { |i| paddings + i*(size+spacing) + (i>=extra_space_idx ? extra_space : 0) }
    end
  end
end

