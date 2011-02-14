module CopyProcess
  class ContentRow
    attr_reader(:type_name, :content, :kw)
  
    def initialize(type_name, content, kw)
      @type_name = type_name
      @content = content
      @kw = kw
    end
  end
end