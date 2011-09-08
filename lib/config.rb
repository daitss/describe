def config_file name
  rel = File.join File.dirname(__FILE__), '..', 'config', name
  File.expand_path rel
end

def xsl_file name
  rel = File.join File.dirname(__FILE__), '..', 'xsl', name
  File.expand_path rel
end

