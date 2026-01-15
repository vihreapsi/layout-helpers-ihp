module IHPQSLib
  include RBA

  class QSLib < Library
    
    def initialize
      self.description = "QoSoC Library for IHP-SG13G2"

      pcells_pth = File.join(File.dirname(__FILE__), "pcells")

      Dir.glob(File.join(pcells_pth, "*.rb")).each do |pcell_file|
        begin
          load pcell_file
          class_name = File.basename(pcell_file, ".rb")
          pcell_class = IHPQSLib.const_get(class_name)
          layout.register_pcell(class_name, pcell_class.new)
        rescue NameError => e
          puts "Class #{class_name} not found in file: #{pcell_file}. Error #{e}"
        rescue => e
          puts "Failed to load the pcell file: #{pcell_file}. Error: #{e}"
        end
      end

      register("QSLib")
    end
  end
  QSLib::new
end

