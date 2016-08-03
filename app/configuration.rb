class GorgLdapDaemon::Configuration

  CONFIG_FILE_PATH=File.expand_path("../../config/config.yml",__FILE__)

  def initialize(env="development")
    @yaml_config = File.exist?(CONFIG_FILE_PATH) ? YAML::load(File.open(CONFIG_FILE_PATH))[env] : {}   
  end

  def [](key)
    env_value(key)|| @yaml_config[key]
  end

  def env_value(key)
    env_var_name="GLD_#{key.to_s.upcase}"
    ENV[env_var_name]
  end
end
