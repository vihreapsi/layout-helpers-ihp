# frozen_string_literal: true

require_relative '../qsbase/qs_box'
require_relative '../qsbase/qs_point'

# IHPQSLib namespace
module IHPQSLib

  # _QSGuardRingCoordinates_ is a class for coordinates computing for elements composing the PSub and the NWell
  # guard ring in every layer. This class can be used for generating a guard ring PCell.
  class QSGuardRingCoordinates
    attr_accessor :type, :width, :height, :iteration, :padding, :clearance, :layer_metal1, :layer_substrate,
                  :layer_cont

    Direction = Struct.new(:north, :south, :east, :west)
    Params = Struct.new(:width, :height, :iteration, :type, :padding, :clearance, :snap_grid)

    def initialize(params = Params.new)

      @width = params.fetch(width, 10)
      @height = params.fetch(height, 10)
      @iteration = params.fetch(:iteration, 1)
      @type = params.fetch(:type, 'psub')
      @padding = params.fetch(:padding, -1)
      @clearance = params.fetch(:clearance, -1)
      @snap_grid = params.fetch(:snap_grid, 5)
      guard_ring_param_checker

      @layer_cont = Direction.new([], [], [], [])
      @layer_metal1 = Direction.new
      @layer_substrate = Direction.new
      @layer_nwell = Direction.new

      # compute
      set_defaults
      compute_metal1
      compute_substrate
      compute_cont
      compute_nwell
    end

    # updates the object variables and recompute the coordinates
    def update(params = {})
      params.each do |key, value|
        setter = "#{key}=".to_sym
        send(setter, value) if respond_to?(setter)
      end
      set_defaults
      compute_metal1
      compute_substrate
      compute_cont
      compute_nwell
      self
    end

    private

    # _set_defaults_ sets some default parameters according to the rules.rb
    def set_defaults
      @padding = if @padding == -1
                   @type == 'psub' ? Rules::PADDING_PSUB : Rules::PADDING_NWELL
                 else
                   @padding
                 end
      @clearance = @clearance == -1 ? Rules::CLEARANCE : @clearance
      puts "Padding: #{@padding}. Clearance: #{@clearance}"
    end

    # metal1 computation
    def compute_metal1
      # Metal1
      one_metal1_size = Rules::CONT_SIZE + @clearance * 2
      metal1_size = one_metal1_size * @iteration
      metal1_expansion = @padding + metal1_size

      @layer_metal1.north = QSBox.new(QSPoint.new(-metal1_expansion, @height + @padding),
                                      @width + metal1_expansion * 2, metal1_size, 'metal1-north')
      @layer_metal1.east = QSBox.new(QSPoint.new(@width + metal1_expansion - metal1_size, -@padding), metal1_size,
                                     @height + @padding * 2, 'metal1-east')
      @layer_metal1.south = QSBox.new(QSPoint.new(-metal1_expansion, -metal1_expansion),
                                      @width + metal1_expansion * 2, metal1_size, 'metal-south')
      @layer_metal1.west = QSBox.new(QSPoint.new(-metal1_expansion, -@padding), metal1_size, @height + @padding * 2,
                                     'metal1-west')

    end

    # substrate computation
    def compute_substrate

      # Substrate / pSD / nBuLay
      substrate_size = (Rules::CONT_SIZE + @clearance * 2) * @iteration + @padding * 2
      substrate_expansion = substrate_size

      @layer_substrate.north = QSBox.new(QSPoint.new(-substrate_expansion, @height),
                                         @width + substrate_expansion * 2, substrate_size, 'substrate-north')
      @layer_substrate.east = QSBox.new(QSPoint.new(@width, 0), substrate_size, @height, 'substrate-east')
      @layer_substrate.south = QSBox.new(QSPoint.new(-substrate_expansion, -substrate_expansion),
                                         @width + substrate_expansion * 2, substrate_size, 'substrate-south')
      @layer_substrate.west = QSBox.new(QSPoint.new(-substrate_expansion, 0), substrate_size, @height,
                                        'substrate-west')
    end

    # contact computation
    def compute_cont
      @layer_cont = Direction.new([], [], [], [])
      cont_size = Rules::CONT_SIZE
      @iteration.times do |i|
        cont_expansion = @padding + (@clearance * 2 + cont_size) * (i + 1) - @clearance
        cont_width = @width + cont_expansion * 2
        cont_height = @height + cont_expansion * 2

        cont_horizon_coord = Utils.fitter(cont_size, cont_width, Rules::CONT_MIN_SPACING, 'c', @snap_grid)
        cont_vertic_coord = Utils.fitter(cont_size, cont_height, Rules::CONT_MIN_SPACING, 'c', @snap_grid)

        cont_horizon_coord.each do |cont|
          # north
          x = -cont_expansion + cont
          y = @height + cont_expansion - cont_size
          @layer_cont.north << QSBox.new(QSPoint.new(x, y), cont_size, cont_size, "cont-north-#{cont}")

          # south
          y = -cont_expansion
          @layer_cont.south << QSBox.new(QSPoint.new(x, y), cont_size, cont_size, "cont-south-#{cont}")

          puts "CONTACT.Horizon: #{cont}"
        end

        cont_vertic_coord.each do |cont|
          # verify for skipping the first and the last contact (already drawn in north and south)
          if cont > cont_vertic_coord[0] && cont < cont_vertic_coord[cont_vertic_coord.length - 1]
            # east
            x = @width + cont_expansion - cont_size
            y = -cont_expansion + cont
            @layer_cont.east << QSBox.new(QSPoint.new(x, y), cont_size, cont_size, "cont-east-#{cont}")

            # west
            x = -cont_expansion
            @layer_cont.west << QSBox.new(QSPoint.new(x, y), cont_size, cont_size, "cont-west-#{cont}")

            puts "CONTACT.Vertic: #{cont}"
          end
        end
      end
    end

    # NWell computation
    def compute_nwell
      nwell_expansion = @padding * 2 + (@clearance * 2 + Rules::CONT_SIZE) * @iteration - Rules::GUARD_RING_NWELL_NBULAY
      @layer_nwell.west = nil
      @layer_nwell.east = nil
      @layer_nwell.south = nil
      @layer_nwell.north = QSBox.new(
        QSPoint.new(-nwell_expansion, -nwell_expansion),
        @width + nwell_expansion * 2,
        @height + nwell_expansion * 2
      )
    end

    # Specific coercing method for guard rings. It operates on the class, independently of the PCell
    # coercing method. It allows:
    # * +width+, +height+ positives(>=0)
    # * +iteration+ >=1
    # * +type+ psub or nwell only (default='psub')
    # * +padding+, +clearance+ >=-1 (default=-1). -1 is using default values of padding/clearance for psub/nwell.
    # * +snap_grid+ the snap grid to follow (default=5): >= 0
    def guard_ring_param_checker
      Utils.arg_checker(
        expression: "Type #{@type} not allowed.",
        condition: %w[psub nwell].include?(@type)
      )
      puts 'Type checked.'

      Utils.arg_checker(
        expression: "Parameters width: #{@width} should be strictly positive.",
        condition: @width.positive?
      )

      Utils.arg_checker(
        expression: "Parameters width: #{@height} should be strictly positive.",
        condition: @height.positive?
      )
      puts 'Width/Height checked.'

      Utils.arg_checker(
        expression: "Parameter iteration: #{@iteration} should be positive greater than 1.",
        condition: @iteration >= 1
      )
      puts 'Iteration checked.'

      Utils.arg_checker(
        expression: "Parameter padding: #{@padding} should be positive or default to -1.",
        condition: @padding >= -1
      )
      Utils.arg_checker(
        expression: "Parameter clearance: #{@clearance} should be positive or default to -1.",
        condition: @clearance >= -1
      )
      puts 'Padding/Clearance checked.'

      Utils.arg_checker(
        expression: "Snap grid should be positive: #{@snap_grid}",
        condition: @snap_grid >= 0
      )
      puts 'Snap grid checked.'
    end
  end
end
