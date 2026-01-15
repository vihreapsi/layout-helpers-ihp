require_relative '../lib/utils'
require_relative '../lib/layers'

module IHPQSLib
  class ContactArray < RBA::PCellDeclarationHelper
    include RBA

    def initialize
      super
      param(:r, TypeInt, "Row", :default=>5)
      param(:c, TypeInt, "Column", :default=>5)
      param(:sp, TypeInt, "Spacing (nm)", :default=>180)
      param(:sz, TypeInt, "Size (nm)", :default=>160, :hidden=>true)
    end

    def display_text_impl
      "ContactArray(#{r.to_s}x#{c.to_s}"
    end

    def coerce_parameters_impl
      if self.sp < 180
        self.sp = 180
      end
    end

    def produce_impl
      self.r.times do |i|
        self.c.times do |j|
          x = i * (self.sz + self.sp)
          y = j * (self.sz + self.sp)
          IHPQSLib::Utils.drect_nm(cell,x,y,self.sz,self.sz,IHPQSLib::Layers::CONT)
        end
      end

    end
  end
end
