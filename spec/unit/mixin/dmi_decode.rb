#
# Author:: Tim Smith (tsmith@chef.io)
# Copyright:: Copyright (c) 2018 Chef Software, Inc.
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

require_relative "../../spec_helper.rb"
require "ohai/mixin/dmi_decode"

describe Ohai::Mixin::DmiDecode, "guest_from_dmi_data" do
  let(:mixin) { Object.new.extend(Ohai::Mixin::DmiDecode) }

  # for the full DMI data used in these tests see https://github.com/chef/dmidecode_collection
  {
    xen: ["Xen", "HVM domU", "4.2.amazon"],
    vmware: ["VMware, Inc.", "VMware Virtual Platform", "None"],
    hyperv: ["Microsoft", "Virtual Machine", "7.0"],
    amazonec2: ["Amazon EC2", "c5n.large", "Not Specified"],
    veertu: ["Veertu", "Veertu", "Not Specified"],
    parallels: ["Parallels Software International Inc.", "Parallels Virtual Platform", "None"],
    vbox: ["Oracle Corporation", "VirtualBox", "1.2"],
    openstack: ["Red Hat Inc.", "OpenStack Nova", "2014.1.2-1.el6"],
    kvm: ["Red Hat", "KVM", "RHEL 7.0.0 PC (i440FX + PIIX, 1996"],
    bhyve: ["", "BHYVE", "1.0"],
  }.each_pair do |hypervisor, values|
    describe "when passed #{hypervisor} dmi data" do
      it "returns '#{hypervisor}'" do
        expect(mixin.guest_from_dmi_data(values[0], values[1], values[2])).to eq("#{hypervisor}")
      end
    end
  end

  describe "When running on RHEV Hypervisor" do
    it "returns 'kvm'" do
      expect(mixin.guest_from_dmi_data("Red Hat", "RHEV Hypervisor", "6.7-20150911.0.el6ev")).to eq("kvm")
    end
  end

  describe "When the manufactuer is 'QEMU'" do
    it "return kvm" do
      expect(mixin.guest_from_dmi_data("QEMU", "", "")).to eq("kvm")
    end
  end

  describe "returns nil if manufactuer is 'Microsoft', but product is not 'Virtual Machine'" do
    it "returns nil" do
      expect(mixin.guest_from_dmi_data("Microsot", "Zune", "2018")).to be_nil
    end
  end

  describe "When running on an unkown system" do
    it "returns nil" do
      expect(mixin.guest_from_dmi_data("TimCorp", "SuperServer", "2018")).to be_nil
    end
  end
end
