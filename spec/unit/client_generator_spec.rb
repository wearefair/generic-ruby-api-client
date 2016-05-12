require 'spec_helper'

describe GenericRubyApiClient::ClientGenerator do
  let(:client_generator) { GenericRubyApiClient::ClientGenerator.new }

  describe '#gem_name' do
    context 'if gem_name is set' do
      it 'returns the gem name' do
        client_generator.gem_name = "test-gem"
        expect(client_generator.gem_name).to eq 'test-gem'
      end
    end
    context 'if gem_name is not set' do
      it 'returns the klass name as the gem_name' do
        client_generator.klass_name = "ThisIsATest"
        expect(client_generator.gem_name).to eq "this-is-a-test"
      end
    end
  end

end
