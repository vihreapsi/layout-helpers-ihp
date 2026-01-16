require_relative '../lib/utils'
require_relative '../lib/layers'

module IHPQSLib
  class GuardRingContact < RBA::PCellDeclarationHelper
    include RBA

    def initialize
      super
      param(:st, TypeString, "Substrate Type", :default=>"psub", :choices=>[
        ["PSub", "psub"],
        ["Nwell", "nwell"]
      ])
      param(:w, TypeInt, "Width (nm)", :default=>0)
      param(:h, TypeInt, "Height (nm)", :default=>0)
      param(:p, TypeInt, "Padding (nm)", :default=>0)
      param(:c, TypeInt, "Clearance", :default=>0)
      param(:n, TypeInt, "Rings", :default=>1)
      param(:m, TypeString, "Mode", :default=>"all", :choices=>[
        ["All", "all"],
        ["North", "north"],
        ["South", "south"],
        ["West", "west"],
        ["East", "east"]
      ])

      # to be used if needed for other layers
      param(:l, TypeLayer, "Layer", :default=>IHPQSLib::Layers::CONT, :hidden=>true)
      param(:sz, TypeInt, "Size (nm)", :default=>160, :hidden=>true)
      param(:ms, TypeInt, "Min. spacing", :default=>180, :hidden=>true)
    end

    def display_text_impl
      "GuardRingContact-#{self.m}"
    end

    def coerce_parameters_impl
      if self.n < 1
        self.n = 1
      end
    end

    def produce_impl
      self.n.times do |n|
        # Horizontal
        ## South
        ### Effective length
        w = self.w + (self.p + (self.sz + self.c) * (n+1) + self.c * n) * 2
        h = self.h + (self.p + (self.sz + self.c) * (n+1) + self.c * n) * 2
        

      end
      puts "Inserted PCell GuardRingContact. ..."
    end
  end
end
