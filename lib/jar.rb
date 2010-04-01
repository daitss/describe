require 'rjb'

module Jar

  def load_jars
    jar_pattern = File.join File.dirname(__FILE__), '..', 'jars', '*.jar'
    j_URI = Rjb.import 'java.net.URL'
    uris = Dir[jar_pattern].map { |f| j_URI.new "file://#{File.expand_path f}" }
    j_URLClassLoader = Rjb.import 'java.net.URLClassLoader'

    if $url_class_loader
      $url_class_loader = j_URLClassLoader.new uris, $url_class_loader
    else
      $url_class_loader = j_URLClassLoader.new uris
    end

  end
  module_function :load_jars

  def import_from_jars name
    j_Class = Rjb.import 'java.lang.Class'
    j_Class.forName name, true, $url_class_loader
  end
  module_function :import_from_jars

end
