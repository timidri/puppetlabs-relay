class PuppetX::Relay::Runner::Dummy
  attr_reader :hostname

  def initialize(hostname)
    @hostname = hostname
  end

  def run
    sleep(5)
    true
  end
end
