Facter.add('puppet_type') do
  setcode do
    if File.readable?('/opt/puppetlabs/server/pe_version')
      'enterprise'
    else
      'oss'
    end
  end
end
