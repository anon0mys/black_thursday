require 'csv'

module Searching
  def data
    CSV.open(@file_path, headers: true, header_converters: :symbol)
  end

  def find_by_id(id)
    all.find {|obj| obj.id == id}
  end

  def find_by_name(name)
    all.find {|obj| obj.name.upcase == name.upcase}
  end
end
