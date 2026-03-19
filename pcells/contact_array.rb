require_relative '../lib/utils'
require_relative '../lib/layers'


module IHPQSLib
  class ContactArray < RBA::PCellDeclarationHelper
    include RBA

    def initialize
      super
      param(:l, TypeLayer, "Layer", default: Layers::CONT)
      param(:r, TypeInt, "Row", default: 5)
      param(:c, TypeInt, "Column", default: 5)
      param(:sz, TypeInt, "Size (nm)", default: 160)
      param(:sp, TypeInt, "Spacing (nm)", default: 180)
      param(:cl, TypeInt, "Clearance (nm)", default: 0)
      param(:sg, TypeInt, "Snap grid (nm)", default: 5)
    end

    def display_text_impl
      "ContactArray(#{self.r}x#{self.c})-#{Utils::RandomName.generate}"
    end

    def coerce_parameters_impl
      self.r = Utils.param_coercer(self.r, 1)
      self.c = Utils.param_coercer(self.c, 1)
      self.sz = Utils.param_coercer(self.sz, 10)
      self.sp = Utils.param_coercer(self.sp, 10)
      self.sg = Utils.param_coercer(self.sg, 0)
      Utils.snap_grid_checker(self.sg, { size: self.sz, spacing: self.sp })
    end

    def draw_array(lyr)
      self.c.times do |i|
        self.r.times do |j|
          x = i * (self.sz + self.sp) + self.cl
          y = j * (self.sz + self.sp) + self.cl
          IHPQSLib::Utils.drectxy(cell, x, y, self.sz, self.sz, lyr)
        end
      end
      puts "Inserted PCell ContactArray. Rows: #{self.r} x Cols: #{self.c}. Size: #{self.sz}nm. Spacing: #{self.sp}nm."
    end

    def produce_impl
      draw_array(self.l)
    end
  end
end
