require 'puppet_x/relay/agent/model/scope'

describe 'Scope model' do
  it 'creates the correct class for a given hash' do
    scope = PuppetX::Relay::Agent::Model::Scope.from_h({'nodes' => ['a.example.com', 'b.example.com']})
    expect(scope).to be_a PuppetX::Relay::Agent::Model::Scope::Nodes
    expect(scope.value).to eq ['a.example.com', 'b.example.com']
    expect(JSON.dump(scope)).to eq %q{{"nodes":["a.example.com","b.example.com"]}}

    scope = PuppetX::Relay::Agent::Model::Scope.from_h({'node_group' => '0b9cc141-c887-4eab-bb80-b7a20b678e3a'})
    expect(scope).to be_a PuppetX::Relay::Agent::Model::Scope::NodeGroup
    expect(scope.value).to eq '0b9cc141-c887-4eab-bb80-b7a20b678e3a'
    expect(JSON.dump(scope)).to eq %q{{"node_group":"0b9cc141-c887-4eab-bb80-b7a20b678e3a"}}
  end
end
