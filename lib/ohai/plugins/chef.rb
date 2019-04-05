#
# Author:: Tollef Fog Heen <tfheen@err.no>
# Copyright:: Copyright (c) 2010 Tollef Fog Heen
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:Chef) do
  provides "chef_packages/chef"

  collect_data(:linux) do
    # welcome to a quick implementation that gets the job done.

    # Try and find chef. If it results in returning us chef its not on the path
    # So we want to look for it in the usual install locations.
    chef_client_bin = which('chef-client') 
    if chef_client_bin.nil?
      if file_exist?('/opt/chef/bin/chef-client')
        chef_client_bin = '/opt/chef/bin/chef-client'
      elsif file_exist?('/opt/chefdk/bin/chef-client')
        chef_client_bin = '/opt/chefdk/bin/chef-client'
      end
    end

    if chef_client_bin
      chef_app_name, version = shell_out("#{chef_client_bin} --version").stdout.chomp.split(' ')

      chef_packages Mash.new unless chef_packages
      chef_packages[:chef] = Mash.new
      chef_packages[:chef][:version] = version

      # There is an assumption that it exists somewhere within this directory.
      # There could multiple and I'm not sure which one would be prefered. I honestly would
      # just put them all into the value here in an array.
      chef_root = shell_out("find /opt -path '*/chef-#{version}/lib'").stdout.chomp.lines.first
      chef_packages[:chef][:chefroot] = chef_root
    end
  end

  collect_data(:windows) do
    # welcome to a quick implementation that gets the job done.
    chef_client_bin = nil
    # Try and find chef. If it results in returning us chef its not on the path
    # So we want to look for it in the usual install locations.
    chef_client_results = shell_out('get-command chef-client | Select-Object -ExpandProperty Definition')
    if chef_client_results.exit_status == 0
      
      chef_client_bin = chef_client_results.stdout.strip
    else
      # TODO: when not found with get-command
    end


    if chef_client_bin
      chef_app_name, version = shell_out("#{chef_client_bin} --version").stdout.chomp.split(' ')

      chef_packages Mash.new unless chef_packages
      chef_packages[:chef] = Mash.new
      chef_packages[:chef][:version] = version

      
      # There is an assumption that it exists somewhere within this directory.
      # There could multiple and I'm not sure which one would be prefered. I honestly would
      # just put them all into the value here in an array.
      # chef_root = shell_out("find /opt -path '*/chef-#{version}/lib'").stdout.chomp.lines.first
      # TODO: the C:\\opscode is assumed here that value should be extracted from the
      chef_base_install_path = chef_client_bin.split("\\")[0..2].join("\\")
      chef_root_results = shell_out("get-childitem -Path #{chef_base_install_path} -Filter chef-#{version}-universal-mingw32 -Directory -Recurse | Select-Object -ExpandProperty FullName")

      if chef_root_results.exit_status == 0
        # There are two entries one in extensions and one in gems
        chef_root = chef_root_results.stdout.strip.split("\r\n")[1]
        chef_packages[:chef][:chefroot] = chef_root
      end
      
    end
  end
end
