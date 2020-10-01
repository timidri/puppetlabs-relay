RSpec.shared_context 'reporting test setup' do
  before(:each) do
    apply_manifest(setup_manifest, catch_failures: true)
    set_sitepp_content(sitepp_content)
  end
  after(:each) do
    set_sitepp_content('')
  end
end
