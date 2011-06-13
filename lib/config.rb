def config_file name
  rel = File.join File.dirname(__FILE__), '..', 'config', name
  File.expand_path rel
end

def xsl_file name
  rel = File.join File.dirname(__FILE__), '..', 'xsl', name
  File.expand_path rel
end

def config_option option
  # load in description service configuration parameter
  describe_config = YAML.load_file config_file('describe.yml')
  describe_config ||= {}
  
  describe_config[option]
end