require "ipaddr"

module Netmon
  module LocalAddressChecker
    CIDR_LIST = [
      IPAddr.new("224.0.0.0/24"), # Local Multicast - IPv4
      IPAddr.new("ff02::/16"),    # Local Multicast - IPv6
      IPAddr.new("0.0.0.0"),      # Unspecified     - IPv4
      IPAddr.new("::")            # Unspecified     - IPv6
    ].freeze

    def self.local?(address)
      ip = IPAddr.new(address)
      return true if ip.link_local?
      return true if ip.loopback?
      return true if ip.private?
      return true if CIDR_LIST.any? { |cidr| cidr.include?(address) }
      false
    end
  end
end
