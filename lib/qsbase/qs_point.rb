# frozen_string_literal: true

module IHPQSLib
  # _QSPoint_ is a class for defining points coordinates.
  # Params:
  # * +x+: x value (default=0.0)
  # * +y+: y value (default=0.0)
  # * +label+: name of a point (optional)
  class QSPoint
    attr_accessor :x, :y, :label

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
