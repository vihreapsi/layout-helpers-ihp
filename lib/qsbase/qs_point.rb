# frozen_string_literal: true

module IHPQSLib
  # _QSPoint_ is a class for defining point coordinates.
  class QSPoint
    attr_accessor :x, :y, :label

    # initialiser
    # @param x [Numeric] x coordinate (default=0.0)
    # @param y [Numeric] y coordinate (default=0.0)
    # @param label [String] name of the point
    # @return [void]
    def initialize(x = 0.0, y = 0.0, label = '')
      @x = x
      @y = y
      @label = label
    end

    # object to string conversion
    def to_s
      lb = (@label != '' ? "[#{@label}]" : '')
      "#{lb}(#{@x};#{@y})"
    end
  end
end
