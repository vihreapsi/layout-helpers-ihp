# frozen_string_literal: true

require_relative 'qs_point'

module IHPQSLib
  # _QSBox_ is a class for defining rectangle shapes.
  class QSBox
    attr_accessor :a, :b, :c, :d, :width, :height, :label

    # QSBox constructor
    # @param p_origin [IHPQSLib::QSPoint] point of origin (left bottom point of the rectangle)
    # @param p_dest_width [Variable] either a QSPoint as the destination point (the right upper point) or width
    # @param height [Numeric] the height of the rectangle, to be provided only if width is used instead of QSPoint.
    # @label [String] the name of the rectangle.
    def initialize(p_origin = 0, p_dest_width = 0, height = nil, label = '')

      # validation and width/height init
      if p_dest_width.zero? && height.nil?
        @width = 0.0
        @height = 0.0
      elsif p_dest_width.is_a?(QSPoint) && height.nil?
        @width = -1
        @height = -1
      elsif p_dest_width.is_a?(Numeric) && height.is_a?(Numeric)
        raise ArgumentError,
              "Arguments width: #{p_dest_width} and height: #{height} should be positive numbers." unless p_dest_width >= 0 && height >= 0
        @width = p_dest_width
        @height = height
      else
        raise ArgumentError, 'Arguments not valid.'
      end

      # attribute init
      @a = p_origin.is_a?(QSPoint) ? p_origin : QSPoint.new
      @c = QSPoint.new
      @b = QSPoint.new
      @d = QSPoint.new

      @label = label

      # box computing
      compute_box
    end

    # Gets the object characteristics in a string.
    # @return [String] a string of object characteristics.
    def to_s
      lb = (@label != '' ? "[#{@label}]" : '')
      "QBox #{lb}(o: #{@a.to_s}. B: #{@b.to_s}. C: #{@c.to_s}. D: #{@d.to_s}. W: #{@width}. H: #{@height})"
    end
    private

    # computing the box according to what is provided.
    # It either computes width, height and point B and D.
    # Or computes points B, C and D if width and height are provided.
    def compute_box
      # if 2 QSPoint provided (point a and point c)
      if width == -1
        # computing width and height
        @width = @c.x - @a.x
        @height = @c.y - @a.y

        # if origin point (point a) and width and height provided
      else
        # compute point c
        @c.x = @a.x + @width
        @c.y = @a.y + @height
      end

      # computing point b
      @b.x = @c.x
      @b.y = @a.y

      # computing point d
      @d.x = @a.x
      @d.y = @c.y
    end
  end
end