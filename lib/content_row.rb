class ContentRow
  attr_reader(:type_name, :content, :kw)
  
  def initialize(content, type_name, kw)
    @type_name = type_name
    @content = content
    @kw = kw
  end
end