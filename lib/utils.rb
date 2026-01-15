module IHPQSLib
  module Utils
    extend self

    def drect_nm(cell,x, y, w, h, layer)
      puts "x: #{x.to_f/1000}um"
      puts "y: #{y.to_f/1000}um"
      puts "w: #{w.to_f/1000}um"
      puts "h: #{h.to_f/1000}um"
      cell.shapes(layer).insert(RBA::DBox.new(x.to_f/1000,y.to_f/1000,(x+w).to_f/1000,(x+h).to_f/1000))
    end
  end
end

