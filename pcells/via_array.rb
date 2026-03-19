require_relative '../lib/utils'
require_relative '../lib/layers'

module IHPQSLib
  class ViaArray < ContactArray
    include RBA

    def initialize
      super
      param(:l, TypeLayer, "Layer", default: Layers::CONT, hidden: true)
      param(:sl, TypeString, "Source Layer", default: "metal1", choices: Layers::METALS_NAMES.map { |lid, dt| [dt[1], lid.to_s] })
      param(:dl, TypeString, "Destination Layer", default: "metal2", choices: Layers::METALS_NAMES.map { |lid, dt| [dt[1], lid.to_s] })
    end

    def display_text_impl
      "ViaArray(#{self.r}x#{self.c})-#{Utils::RandomName.generate}"
    end

    def coerce_parameters_impl
      self.r = Utils.param_coercer(self.r, 1)
      self.c = Utils.param_coercer(self.c, 1)
      self.sz = Utils.param_coercer(self.sz, 10)
      self.sp = Utils.param_coercer(self.sp, 10)
      self.sg = Utils.param_coercer(self.sg, 0)
      Utils.snap_grid_checker(self.sg, { size: self.sz, spacing: self.sp })
    end

    def produce_impl
      w = self.sz * self.c + self.sp * (self.c - 1) + self.cl * 2
      h = self.sz * self.r + self.sp * (self.r - 1) + self.cl * 2
      metal_stack = Utils.get_metal_stack(Layers::METALS_NAMES[self.sl.to_sym][0], Layers::METALS_NAMES[self.dl.to_sym][0])
      
      if !metal_stack.nil?
        metal_stack.each do |st|
          # draw metal
          if Layers::METALS.include?(st)
            Utils.drectxy(cell, 0, 0, w, h, st)
          end

          # draw via array
          if Layers::VIAS.include?(st)
            draw_array(st)
          end
        end
        puts "Inserted PCell ViaArray from #{metal_stack.first} to #{metal_stack.last}. Rows: #{self.r} x Cols: #{self.c}. Size: #{self.sz}nm. Spacing: #{self.sp}nm."
      else
        puts "Stack not permitted"
      end

    end

  end

end