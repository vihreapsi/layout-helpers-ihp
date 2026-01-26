require_relative '../lib/utils'
require_relative '../lib/layers'

module IHPQSLib
  class ContactLine < RBA::PCellDeclarationHelper
    include RBA

    def initialize
      super
      param(:l, TypeLayer, 'Layer', default: IHPQSLib::Layers::CONT)
      param(:len, TypeInt, 'Length (nm)', default: 1000)
      param(:sz, TypeInt, 'Size (nm)', default: 160)
      param(:ms, TypeInt, 'Min. Spacing (nm)', default: 180)
      param(:p, TypeInt, 'Paddings (nm)', default: 0)
      param(:sg, TypeInt, 'Snap Grid (nm)', default: 5)
      param(:pos, TypeString, 'Extra Space Position', default: 'l', choices: [
              ['Left', 'l'],
              ['Center', 'c'],
              ['Right', 'r']
            ])
      param(:n, TypeInt, 'Num. of Line(s)', default: 1)
      param(:vst, TypeString, ' Vertical Spacing Type', default: 'sq', choices: [
              ['Square', 'sq'],
              ['Min. Spacing', 'ms'],
              ['Custom vertical spacing', 'cvs'],
            ])
      param(:cvs, TypeInt, 'Custom vertical spacing', default: 180)
    end

    def display_text_impl
      "ContactLine(#{self.sz.to_s} in #{self.len.to_s})"
    end

    def coerce_parameters_impl
      self.n = Utils.param_coercer(self.n, 'spos')
      self.len = Utils.param_coercer(self.len, 'pos')
      self.sz = Utils.param_coercer(self.sz, 'pos')
      self.p = Utils.param_coercer(self.p, 'pos')
      self.ms = Utils.param_coercer(self.ms, 'pos')
      self.cvs = Utils.param_coercer(self.cvs, 'pos')
      self.sg = Utils.param_coercer(self.sg, 'pos')
      Utils.snap_grid_checker(self.sg, { length: self.len, size: self.sz, min_spacing: self.ms, paddings: self.p })
    end

    def produce_impl
      # placement computing
      cont_coord = Utils.fitter(self.sz, self.len, self.ms, self.pos, self.sg, self.p)

      # vertical spacing
      vertical_spacing = case self.vst
                         when 'sq' then (self.pos != 'l') ? cont_coord[1]-self.sz : cont_coord[cont_coord.length-1]-cont_coord[cont_coord.length-2]-self.sz
                         when 'ms' then self.ms
                         when 'cvs' then self.cvs
                         else 180
                         end

      self.n.times do |c|
        cont_coord.each do |i|
          Utils.drectxy(cell, i, c * (self.sz+vertical_spacing), self.sz, self.sz, self.l)
        end
      end
      puts "Inserted PCell ContactLine. #{self.n} Line(s) with #{self.sz}"
    end
  end
end
