require "elibri_thema/version"
require "elibri_thema/config"
require "nokogiri"

module ElibriThema

  def self.flat_categories
    dom = Nokogiri::XML(File.read(Config.new.root + "assets/Thema_v1.3.2_pl.xml"))
    @flat_categories ||= dom.css("Code").map  do |code|
      { code: code.css("CodeValue")[0].inner_text, 
        name: code.css("CodeDescription")[0].inner_text, 
        remarks: code.css("CodeNotes")[0].inner_text,
        parent_code: code.css("CodeParent")[0].inner_text == "" ? nil : code.css("CodeParent")[0].inner_text }
    end
  end


  #nie interesują nas te poddrzewa - oszczędzamy czas ładowania, szybciej też będzie działać wyszukiwanie
  def self.unused_subtrees
    ["4Z-CA-", "4Z-CB-", "4Z-DE-", "4Z-DK-", "4Z-ES-", "4Z-FR-", "4Z-GB-", "4Z-IE-", "4Z-IT-", "4Z-US-", "4Z-AA-",
     "4Z-AR-", "4Z-BO-", "4Z-CL-", "4Z-CO-", "4Z-CR-", "4Z-CU-", "4Z-DO-", "4Z-EC-", "4Z-FI-", "4Z-GT-", "4Z-HN-",
     "4Z-MX-", "4Z-NI-", "4Z-NO-", "4Z-PA-", "4Z-PE-", "4Z-PY-", "4Z-SV-", "4Z-UY-", "4Z-VE-"]

  end

  #tych kodów nie da się przypisać do książek
  def self.blocked_codes
    ["XQ", "XA", "FY", "5A", "5H", "5J", "5L", "5P"] +
    ["6A", "6B", "6C", "6D", "6E", "6F", "6G", "6H", "6J", "6K", "6L", "6M", "6N", "6P", "6Q", "6R", "6S", "6T", "6U", "6V", "6W", "6X"] +
    ["4C", "4G", "4L", "4T", "4Z", "4Z-PL-"]
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

  def self.category_full_names(tree = ElibriThema::nested_categories, parent_names = nil)
     categories = {}
     tree.each do |cat|
       full_category_name = [parent_names, cat[:name]].compact.join(" / ")
       categories[cat[:code]] = full_category_name
       categories.merge!(category_full_names(cat[:children], full_category_name))
     end

    return categories
  end
end
