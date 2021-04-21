#
# Cookbook:: refreshenv
# Resource:: refresh_env
#

# A useful resource to refresh the ENV variable in Ruby during a chef client run.
# You can use this in any recipe within a cookbook that depends on refreshenv.
# This resource handles both SYSTEM and USER environment variables.
#
# Use: simply call the resource and give it an name_property of your choice.
#   refresh_env 'Refreshing Environment Variables' do
#     action :create
#   end
#
resource_name :refresh_env
provides :refresh_env

actions :create
default_action :create

system_env_registry_path = 'HKLM\System\CurrentControlSet\Control\Session Manager\Environment'
user_env_registry_path = 'HKCU\Environment'
volatile_env_registry_path = 'HKCU\Volatile Environment'

def resolve_windows_variables(env, system_env_from_registry)
  replacement_env = Hash.new {}
  variables_to_replace = env.scan(/%\w+%/)

  variables_to_replace.each do |variable|
    variable = variable.gsub! '%', ''
    in_registry = system_env_from_registry.select { |env_value| env_value[:name] == variable }.count == 1

    if in_registry
      replace_value = system_env_from_registry.find { |env_value| env_value[:name] == variable }[:data]
    else
      if variable == 'SystemRoot'
        variable = 'windir'
        replace_value = ENV[variable]
        variable = 'SystemRoot'
      end
      replace_value = ENV[variable]
    end

    replacement_env[variable] = replace_value
  end

  replacement_env.each_pair do |key, value|
    env.gsub! "%#{key}%", value
  end

  env
end

action :create do
  system_env_from_registry = registry_get_values(system_env_registry_path)
  user_env_from_registry = registry_get_values(user_env_registry_path)
  volatile_env_from_registry = Hash.new {}

  begin
    volatile_env_from_registry = registry_get_values(volatile_env_registry_path)
  rescue Chef::Exceptions::Win32RegKeyMissing
    puts "The #{volatile_env_registry_path} registry path was not found, continuing refresh of environment variables..."
  end

  ENV.each_key do |key|
    is_system_env_variable = system_env_from_registry.select { |env_value| env_value[:name] == key }.count == 1
    is_user_env_variable = user_env_from_registry.select { |env_value| env_value[:name] == key }.count == 1
    is_volatile_env_variable = volatile_env_from_registry.select { |env_value| env_value[:name] == key }.count == 1

    next if is_volatile_env_variable

    if key == 'Path'
      system_env_variable = system_env_from_registry.find { |env_value| env_value[:name] == key }[:data]

      if is_user_env_variable
        user_env_variable = user_env_from_registry.find { |env_value| env_value[:name] == key }[:data]
      end

      unresolved_env_variable = is_user_env_variable ? "#{system_env_variable};#{user_env_variable}" : system_env_variable.to_s
      ENV[key] = resolve_windows_variables(unresolved_env_variable, system_env_from_registry)
    elsif is_user_env_variable && is_system_env_variable
      unresolved_env_variable = user_env_from_registry.find { |env_value| env_value[:name] == key }[:data]
      ENV[key] = resolve_windows_variables(unresolved_env_variable, system_env_from_registry)
    elsif is_system_env_variable
      unresolved_env_variable = system_env_from_registry.find { |env_value| env_value[:name] == key }[:data]
      ENV[key] = resolve_windows_variables(unresolved_env_variable, system_env_from_registry)
    end
  end
end
