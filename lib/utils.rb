# frozen_string_literal: true

require_relative 'rules'

# IHPQSLib namespace
module IHPQSLib

  # defines utility functions
  module Utils
    extend self

    # _drectxy_ draws a rectangle in nanometers on a specific layer
    # @param [Cell] cell is the cell on which the rectangle will be drawn
    # @param [Float] x is x coordinates of the rectangle
    # @param [Float] y is y coordinates of the rectangle
    # @param [Float] w is the width of the rectangle
    # @param [Float] h is the height of the rectangle
    # @param [Layer] layer is the layer where to draw the rectangle
    def drectxy(cell, x, y, w, h, layer)
      arg_checker(
        expression: 'x should be a number',
        condition: x.is_a?(Numeric)
      )
      arg_checker(
        expression: 'y should be a number',
        condition: y.is_a?(Numeric)
      )
      arg_checker(
        expression: 'w should be a number',
        condition: w.is_a?(Numeric)
      )
      arg_checker(
        expression: 'h should be a number',
        condition: h.is_a?(Numeric)
      )
      cell.shapes(layer).insert(RBA::DBox.new(x.to_f / 1000, y.to_f / 1000, (x + w).to_f / 1000, (y + h).to_f / 1000))
    end

    # _drect_ draws a rectangle in nanometers on a specific layer
    # @param [Cell] cell is the cell on which the rectangle will be drawn
    # @param [QSPoint] o is the origin point of QSPoint type (the point A situated on the left-bottom corner)
    # @param [Float] w is the width of the rectangle
    # @param [Float] h is the height of the rectangle
    # @param [Layer] layer is the layer where to draw the rectangle
    def drect(cell, o, w, h, layer)
      arg_checker(
        expression: 'o should be of type QSPoint provided ~param~',
        condition: o.is_a?(QSPoint),
        name: o.class,
        value: o.to_s
      )
      cell.shapes(layer).insert(RBA::DBox.new(o.x.to_f / 1000, o.y.to_f / 1000, (o.x + w).to_f / 1000,
                                              (o.y + h).to_f / 1000))
    end

    # The _fitter_ computes in nanometer coordinates of equally sized and equally spaced lines (_sprinkles_)
    # within a given length line. It follows strict grid snapping and be constrained
    # to a minimum spacing.
    # @param [Float] sprinkle_size the length of the sprinkles
    # @param [Float] sprinkle_length the length of the sprinkle container
    # @param [Float] min_spacing the minimum spacing constraint
    # @param [Float] position extra space position:
    # * +'l'+: left (default)
    # * +'r'+: right
    # * +'c'+: center
    # @param [Float] snap_grid the grid constraint snapping
    # @param [Float] paddings consider a padding at start and end of the sprinkle container
    # @return [Array] array of calculated coordinates of origin point of the sprinkles.
    def fitter(sprinkle_size, sprinkle_length, min_spacing, position='l', snap_grid=5, paddings=0)
      ## Argument validation
      # size fitting on length + paddings
      arg_checker(
        expression: "Size of one sprinkle #{sprinkle_size} can't fit in length #{sprinkle_length}",
        condition: (sprinkle_length - (paddings * 2)) > sprinkle_size
      )

      # snap grid check for: size, length and min. spacing
      Utils.snap_grid_checker(snap_grid, { size: sprinkle_size, length: sprinkle_length, min_spacing: min_spacing })

      ## Computing
      # Effective length
      l = sprinkle_length - (paddings * 2)

      # Number of sprinkles
      sprinkle_number = ((l - sprinkle_size) / (sprinkle_size + min_spacing)) + 1

      # Remaining space
      rs = (l - sprinkle_size) % (sprinkle_size + min_spacing)
      puts "Remaining space: #{rs}"

      # distribute remaining space
      spacing = min_spacing + rs / (sprinkle_number - 1).floor if sprinkle_number > 1

      puts "Spacing => #{spacing}"

      # Extra space
      extra_space = (l - sprinkle_size) % (sprinkle_size + spacing)

      # Extra space position
      extra_space_idx = case position
                        when 'c' then sprinkle_number / 2
                        when 'r' then (sprinkle_number - 1)
                        else 1
                        end

      ## Coordinates computing
      Array.new(sprinkle_number) { |i| paddings + i * (sprinkle_size + spacing) + (i >= extra_space_idx ? extra_space : 0) }
    end

    # _arg_checker_ checks for arguments and raise error if condition is not met. It parses the string +~param~+
    # included in the argument +expression+ and place instead +name+: +value+
    # @param [String] expression the error that will be displayed.
    # @param [Boolean] condition the condition for _NOT_ raising the error.
    # If condition is +false+ the error will raise.
    # @param [String] name the name of the argument that will be checked, if defined, it will be included in expression or in the internal default expression that will be displayed.
    # @param value the value of the argument that will be checked, if defined, it will be included in expression or in the internal default expression that will be displayed.
    # @raise [ArgumentError] if the condition doesn't meet.
    def arg_checker(expression:, condition:, name: nil, value: nil)
      name_value = [name, value].compact.join(': ')

      exp = if expression.nil?
              "Argument #{name_value} not valid."
            else
              name_value.nil? || name_value != '' ? expression.gsub('~param~', '') : expression.gsub('~param~', name_value)
            end
      raise ArgumentError, exp unless condition
    end

    # _snap_grid_checker_ checks if +params+ are snapping to grid spaced with +snap_grid+
    def snap_grid_checker(snap_grid, params)
      return unless snap_grid.positive?

      params.each do |key, val|
        if !val.nil? && ((val % snap_grid) != 0)
          raise "Error. #{key.capitalize}: #{val} doesn't snap to grid #{snap_grid}"
        end
      end
    end

    # _param_coercer_ is a method for coercing parameter in PCells creation.
    # It accepts keywords for number main intervals: zero, (strictly) positive/negative.
    # Or a limitations with +val_min+ as minimum value and +val_max+ as maximum value.
    # @param param parameters to be coerced
    # @param val_min minimum value of the parameter or a keyword
    # @param val_max maximum value of the parameter
    # @return the coerced parameter
    def param_coercer(param, val_min = nil, val_max = nil)
      return nil if param.nil?

      # named constraints
      if val_min.is_a?(String) && val_max.nil?
        constr = {
          'spos' => ->(p) { p.positive? ? p : 1 },
          'sneg' => ->(p) { p.negative? ? p : -1 },
          'pos' => ->(p) { p >= 0 ? p : 0 },
          'positive' => ->(p) { p >= 0 ? p : 0 },
          'neg' => ->(p) { p <= 0 ? p : 0 },
          'negative' => ->(p) { p <= 0 ? p : 0 },
          'z' => ->(p) { p.zero? ? p : 0 },
          'zero' => ->(p) { p.zero? ? p : 0 }
        }

        raise ArgumentError, "Invalid argument: #{val_min}" unless constr.key?(val_min)

        constr[val_min].call(param)
      elsif (val_min.is_a?(Numeric) && val_max.nil?) ||
            (val_min.nil? && val_max.is_a?(Numeric)) ||
            (val_min.is_a?(Numeric) && val_max.is_a?(Numeric))
        min = val_min.is_a?(Numeric) ? val_min : -Float::INFINITY
        max = val_max.is_a?(Numeric) ? val_max : Float::INFINITY

        raise ArgumentError, "Invalid arguments: min > max. Got min=#{min} and max=#{max}" unless min < max

        param.clamp(min, max)
      else
        raise ArgumentError, "Arguments not valid: #{val_min}/#{val_max}"
      end
    end

    # _RandomName_ generates random pair of adjective-name for instance naming.
    # Usage:
    #   RandomName.generate    # for adjective-name combination.
    #   RandomName.generate(n) # for n_adjective(s)-name combination.
    class RandomName
      ADJECTIVES = %w[
        ancient bitter cold damp eerie fast great hard icy jolly keen light misty noble odd
        pale quick rare soft thin urban vast wild young zinc agile brave calm dark elite firm
        glum harsh iron jade kind lush mild neat oval pure rich sour tiny unit vivid warm
        xylo yielding zeal aloft brisk crisp deep epic foul grim high inch jump knob long
        mute navy open posh quit rosy silk tall uppy vest wry xeric yern zero acid bent
        cool dull easy flat glad hazy into jaunty kinky lazy mega numb oily pink quad rude
        salt trim ugly vice wide x-ray yellow zest
      ].freeze

      NAMES = %w[
        atlas beacon cloud drake echo falcon gaze hawk iron junction kite lunar mesa nova
        orbit pulse quartz river solar titan unit vapor wolf xenolith yard zenith arch
        bolt core drift edge flux gate hum ion jolt keel link moss node onyx path quark
        reef spark tide upwash void wave xonotlite yonder zone apex bark cliff dune east
        fin gulf hill isle jaw knob leaf mind north oak peak quest ridge storm trail
        under vale wall xylem york zircon abyss bluff creek dell eve frost grove hill
        ink jet krill lake mount net out post quill rock spire tree urn vent wood
      ].freeze

      # Generator
      # @return return a random adjective(s)-name combination
      def self.generate(num = 1)
        !num.is_a?(Integer) ? num = 1 : nil
        num < 1 ? num = 1 : nil

        "#{ADJECTIVES.sample(num).join('-')}-#{NAMES.sample}"
      end
    end

  end
end

