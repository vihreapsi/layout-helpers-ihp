require_relative '../lib/utils'
require_relative '../lib/layers'
require_relative '../lib/rules.rb'


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
      param(:im, TypeString, "Include Metal", default: 'y', choices: [
        ['Yes', 'y'],
        ['No', 'n']
      ])
      param(:iga, TypeString, "Include GatPoly/Activ", default: 'n', choices: [
        ['Gatploy', 'g'],
        ['Activ', 'a'],
        ['No', 'n']
      ])
      param(:enc, TypeString, "Enclosure", default: 'n', choices: [
        ['One side', 'o'],
        ['None', 'n']
      ])
      param(:encpos, TypeString, "Enclosure position", default: 'h', choices: [
        ['Horizontal', 'h'],
        ['Vertical', 'v']
      ])
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
      metal1_rule = (self.im == 'y') ? Rules::CONT_METAL1_MIN_ENCLOSURE : 0
      gatpoly_rule = (self.iga != 'n') ? Rules::CONT_GATPOLY_MIN : 0
      clearance_rule = metal1_rule > gatpoly_rule ? metal1_rule : gatpoly_rule 
      self.c.times do |i|
        self.r.times do |j|
          x = i * (self.sz + self.sp) + self.cl + clearance_rule
          y = j * (self.sz + self.sp) + self.cl + clearance_rule
          IHPQSLib::Utils.drectxy(cell, x, y, self.sz, self.sz, lyr)
        end
      end
      puts "Inserted PCell ContactArray. Rows: #{self.r} x Cols: #{self.c}. Size: #{self.sz}nm. Spacing: #{self.sp}nm."
    end

    def draw_metal1()
      case self.enc
      when 'o'
        if self.encpos == 'h'
          enclosure_w = 0
          enclosure_l = Rules::CONT_METAL1_MIN_ENCLOSURE
        else
          enclosure_w = Rules::CONT_METAL1_MIN_ENCLOSURE
          enclosure_l = 0
        end
      else
        enclosure_w = 0
        enclosure_l = 0
      end
      if self.iga != 'n'
        x = Rules::CONT_GATPOLY_MIN - Rules::CONT_METAL1_MIN_ENCLOSURE
        y = Rules::CONT_GATPOLY_MIN - Rules::CONT_METAL1_MIN_ENCLOSURE
      else
        x = 0
        y = 0
      end
      w = self.sz * self.c + self.cl * 2 + (self.sp * (self.c - 1)) + Rules::CONT_METAL1_MIN_ENCLOSURE * 2 - enclosure_w
      l = self.sz * self.r + self.cl * 2 + (self.sp * (self.r - 1)) + Rules::CONT_METAL1_MIN_ENCLOSURE * 2 - enclosure_l
      IHPQSLib::Utils.drectxy(cell, x, y, w, l, Layers::METAL1)
    end

    def draw_gatpoly_activ(lyr)
      w = self.sz * self.c + self.cl * 2 + (self.sp * (self.c - 1)) + Rules::CONT_GATPOLY_MIN * 2
      l = self.sz * self.r + self.cl * 2 + (self.sp * (self.r - 1)) + Rules::CONT_GATPOLY_MIN * 2
      IHPQSLib::Utils.drectxy(cell, 0, 0, w, l, lyr)
    end

    def produce_impl
      draw_array(self.l)
      draw_metal1 if self.im == 'y'
      case self.iga
      when 'g'
        draw_gatpoly_activ(Layers::GATPOLY)
      when 'a'
        draw_gatpoly_activ(Layers::ACTIV)
      end
    end
  end
end
