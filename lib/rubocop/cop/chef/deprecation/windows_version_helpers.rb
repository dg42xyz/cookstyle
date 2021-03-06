# frozen_string_literal: true
#
# Copyright:: 2019-2020, Chef Software, Inc.
# Author:: Tim Smith (<tsmith@chef.io>)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module RuboCop
  module Cop
    module Chef
      module ChefDeprecations
        # Use node['platform_version'] and node['kernel'] data instead of the deprecated Windows::VersionHelper helpers from the Windows cookbook.
        #
        # @example
        #
        #   # bad
        #   Windows::VersionHelper.nt_version
        #   Windows::VersionHelper.server_version?
        #   Windows::VersionHelper.core_version?
        #   Windows::VersionHelper.workstation_version?
        #
        #   # good
        #   node['platform_version'].to_f
        #   node['kernel']['product_type'] == 'Server'
        #   node['kernel']['server_core']
        #   node['kernel']['product_type'] == 'Workstation'
        #
        class WindowsVersionHelpers < Cop
          extend TargetChefVersion

          minimum_target_chef_version '14.0'

          MSG = "Use node['platform_version'] and node['kernel'] data introduced in Chef Infra Client 14 instead of the deprecated Windows::VersionHelper helpers from the Windows cookbook."

          def_node_matcher :windows_helper?, <<-PATTERN
            (send ( const ( const {nil? cbase} :Windows ) :VersionHelper ) $_ )
          PATTERN

          def on_send(node)
            windows_helper?(node) do
              add_offense(node, location: :expression, message: MSG, severity: :refactor)
            end
          end

          def autocorrect(node)
            lambda do |corrector|
              windows_helper?(node) do |method|
                case method
                when :nt_version
                  corrector.replace(node.loc.expression, 'node[\'platform_version\'].to_f')
                when :server_version?
                  corrector.replace(node.loc.expression, 'node[\'kernel\'][\'product_type\'] == \'Server\'')
                when :core_version?
                  corrector.replace(node.loc.expression, 'node[\'kernel\'][\'server_core\']')
                when :workstation_version?
                  corrector.replace(node.loc.expression, 'node[\'kernel\'][\'product_type\'] == \'Workstation\'')
                end
              end
            end
          end
        end
      end
    end
  end
end
