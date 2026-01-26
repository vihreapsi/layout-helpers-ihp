# frozen_string_literal: true

module IHPQSLib
  # _GuardRingLayerCoordinate_ is an abstract class for calculating layer coordinates for guard rings.
  class QSGuardRingLayerCoordinates
    Params = Struct.new(:iteration, :type, :padding, :clearance, :snap_grid)
    def initialize(width, height, params = Params.new)
      @width = width
      @height = height
      @type = params.fetch(:type, 'psub')
      @iteration = params.fetch(:iteration, 1)
      @padding = params.fetch(:padding, -1)
      @clearance = params.fetch(:clearance, -1)
      @snap_grid = params.fetch(:snap_grid, 5)
      Utils.guard_ring_param_checker(@width, @height, @iteration, @type, @padding, @clearance, @snap_grid)
    end
  end
end
