require 'spec_helper'

RSpec.describe 'fluentd' do
  shared_examples 'works' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('fluentd') }
    it { is_expected.to contain_class('fluentd::install') }
    it { is_expected.to contain_class('fluentd::service') }
  end

  context 'with debian', :debian do
    include_examples 'works'
  end

  context 'with redhat', :redhat do
    include_examples 'works'
  end

  context 'with plugins', :redhat do
    let(:params) { { plugins: { plugin_name => plugin_params } } }

    let(:plugin_name) { 'fluent-plugin-http' }
    let(:plugin_params) { { 'plugin_ensure' => '0.1.0' } }

    it { is_expected.to contain_fluentd__plugin(plugin_name).with(plugin_params) }
  end
end
