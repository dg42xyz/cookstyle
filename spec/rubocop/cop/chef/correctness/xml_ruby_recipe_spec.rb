#
# Copyright:: 2019, Chef Software, Inc.
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

require 'spec_helper'

describe RuboCop::Cop::Chef::IncludingXMLRubyRecipe, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense when a recipe includes "xml::ruby"' do
    expect_offense(<<~RUBY)
      include_recipe 'xml::ruby'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ The xml::ruby recipe installs nokogiri which is included in Chef Infra Client 12 and later.
    RUBY
  end

  it "doesn't register an offense when a recipe includes another recipe" do
    expect_no_offenses(<<~RUBY)
      include_recipe 'xml::other_thing'
    RUBY
  end
end