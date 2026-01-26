require_relative '../lib/utils'
require_relative '../lib/layers'
require_relative '../lib/pcabs/qs_guard_ring_coordinates'

module IHPQSLib
  class GuardRing < RBA::PCellDeclarationHelper
    include RBA

    def initialize
      super
      param(:st, TypeString, 'Substrate Type', default: 'psub', choices: [
        ['PSub', 'psub'],
        ['Nwell', 'nwell']
      ])
      param(:w, TypeInt, 'Width (nm)', default: 500)
      param(:h, TypeInt, 'Height (nm)', default: 500)
      param(:p, TypeInt, 'Padding (nm)', default: -1)
      param(:c, TypeInt, 'Clearance (nm)', default: -1)
      param(:n, TypeInt, 'Rings', default: 1)
      param(:m, TypeString, 'Mode', default: 'all', choices: [
        ['All', 'all'],
        ['North', 'north'],
        ['South', 'south'],
        ['West', 'west'],
        ['East', 'east']
      ])
      param(:sg, TypeInt, 'Grid snap', default: 5)

      # to be used if needed for other layers
      param(:l, TypeLayer, 'Layer', default: Layers::CONT, hidden: true)
      param(:sz, TypeInt, 'Size (nm)', default: 160, hidden: true)
      param(:ms, TypeInt, 'Min. spacing (nm)', default: 180, hidden: true)

      @guard_ring = IHPQSLib::QSGuardRingCoordinates.new(width: 1000, height: 1000)
    end

    def display_text_impl
      "GuardRing(#{Utils::RandomName.generate}[#{self.m.capitalize}])"
    end

    def coerce_parameters_impl
      Utils.snap_grid_checker(self.sg, { width: self.w, height: self.h })
      self.w = Utils.param_coercer(self.w, 10)
      self.h = Utils.param_coercer(self.h, 10)
      self.p = Utils.param_coercer(self.p, 'sneg')
      self.c = Utils.param_coercer(self.c, 'sneg')
      self.n = Utils.param_coercer(self.n, 'spos')
      self.sg = Utils.param_coercer(self.sg, 'pos')
    end

    def produce_impl
      # update PCell params -> @guard_ring
      attrs = { width: self.w, height: self.h, iteration: self.n, type: self.st, padding: self.p, clearance: self.c, snap_grid: self.sg }
      @guard_ring.update(attrs)

      # drawing for PSub or NWell
      case self.st
      when 'nwell'
        drawer('metal1+nbulay+cont', self.m)
        drawer('nwell', 'north') if self.m == 'all'
      else
        drawer('metal1+substrate+psd+cont', self.m)
      end
      puts 'Inserted PCell GuardRing. ...'
    end

    # _drawer_ draws the Guard Ring according to the coordinates calculation made by {GuardRingCoordinates}[IHPQSLib::Utils.GuardRingCoordinates]
    def drawer(layer_name, direction = 'all')
      layer_name.split('+').each do |layer|
        layer_instance_name = %w[substrate psd nbulay].include?(layer) ? '@layer_substrate' : "@layer_#{layer.downcase}"
        @guard_ring.instance_variables.select { |v| v.to_s.start_with?(layer_instance_name) }.each do |var|
          lyr = @guard_ring.instance_variable_get(var)
          lyr.each_pair do |dir, boxes|
            next if boxes.nil?

            boxes = boxes.is_a?(Array) ? boxes : [boxes]
            boxes.each do |box|
              if dir.to_s == direction || direction == 'all'
                puts "Drawing: #{box.label} in coordinates: #{box}"
                Utils.drect(cell, box.a, box.width, box.height, Layers.const_get(layer.upcase))
              end
            end
          end
        end
      end
    end

  end
end
