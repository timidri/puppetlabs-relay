require 'puppet_litmus'
require 'spec_acceptance_helper_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_acceptance_helper_local.rb'))
include PuppetLitmus

PuppetLitmus.configure!
