require_relative '../lib/utils'
require_relative '../lib/layers'

module IHPQSLib
  class ContactLine < RBA::PCellDeclarationHelper
    include RBA

    def initialize
      super
      param(:l, TypeLayer, "Layer", :default=>IHPQSLib::Layers::CONT)
      param(:len, TypeInt, "Length (nm)", :default=>1000)
      param(:sz, TypeInt, "Size (nm)", :default=>160)
      param(:ms, TypeInt, "Min. Spacing (nm)", :default=>180)
      param(:p, TypeInt, "Paddings (nm)", :default=>0)
      param(:sg, TypeInt, "Snap Grid (nm)", :default=>5)
      param(:pos, TypeString, "Extra Space Position", :default=>"l", :choices=>[
        ["Left", "l"],
        ["Center", "c"],
        ["Right", "r"]
      ])
      param(:n, TypeInt, "Num. of Line(s)", :default=>1)
    end

    def display_text_impl
      "ContactLine(#{self.sz.to_s} in #{self.len.to_s})"
    end

    def coerce_parameters_impl
      if self.n < 1
        self.n = 1
      end

      if self.len < 0
        self.len = 0
      end

      if self.sz < 0
        self.sz = 0
      end

      if self.p < 0
        self.p = 0
      end

      if self.ms < 0
        self.ms = 0
      end

      if self.sg > 0
        if (self.len % self.sg) != 0
          raise "Error: Length #{self.len} doesn't snap to grid #{self.sg}"
        end
        
        if (self.sz % self.sg) != 0
          raise "Error: Size #{self.sz} doesn't snap to grid #{self.sg}"
        end

        if (self.ms % self.sg) != 0
          raise "Error: Min. Spacing #{self.ms} doesn't snap to grid #{self.sg}"
        end

        if (self.p % self.sg) != 0
          raise "Error: Paddings #{self.p} doesn't snap to grid #{self.sg}"
        end
      elsif self.sg < 0
        self.sg = 0
      end

    end

    def produce_impl
      # placement computing
      cont_coord = IHPQSLib::Utils.fitter(self.sz, self.len, self.ms, self.pos, self.sg, self.p)
      cont_coord.each do |i|
        IHPQSLib::Utils.drect(cell, i, 0, self.sz, self.sz, self.l)
      end
      puts "Inserted PCell ContactLine. #{self.n} Line(s) with #{self.sz}"
    end
  end
end
