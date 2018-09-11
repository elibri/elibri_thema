require "elibri_thema/version"
require "elibri_thema/config"
require "nokogiri"

module ElibriThema

  def self.flat_categories
    dom = Nokogiri::XML(File.read(Config.new.root + "assets/Thema_v1.3.0_pl.xml"))
    @flat_categories ||= dom.css("Code").map  do |code|
      { code: code.css("CodeValue")[0].inner_text, 
        name: code.css("CodeDescription")[0].inner_text, 
        remarks: code.css("CodeNotes")[0].inner_text,
        parent_code: code.css("CodeParent")[0].inner_text == "" ? nil : code.css("CodeParent")[0].inner_text }
    end
  end

  def self.nested_categories
     by_code = {}
     root_categories = []
     flat_categories.map(&:dup).each do |category|
       category[:children] = []
       by_code[category[:code]] = category
       if category[:parent_code]
         by_code[category[:parent_code]][:children] << category
       else
         root_categories << category
       end
     end

     return root_categories
  end
end
