# =============================================================================
# MikroTik Interfaces Module - Basic Functionality Tests
# =============================================================================

# Mock provider configuration for testing without real RouterOS device
mock_provider "routeros" {}

# Test 1: Create single bridge
run "single_bridge" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        comment = "Test bridge"
      }
    }
  }
  
  assert {
    condition     = routeros_interface_bridge.this["bridge1"].name == "bridge1"
    error_message = "Bridge name should match key"
  }
  
  assert {
    condition     = routeros_interface_bridge.this["bridge1"].vlan_filtering == false
    error_message = "VLAN filtering should be disabled by default"
  }
}

# Test 2: Create VLAN interface
run "single_vlan" {
  command = plan
  
  variables {
    vlans = {
      "10" = {
        vlan_id   = 10
        interface = "bridge1"
        comment   = "Management VLAN"
      }
    }
  }
  
  assert {
    condition     = routeros_interface_vlan.this["vlan10"].name == "vlan10"
    error_message = "VLAN name should match key"
  }
  
  assert {
    condition     = routeros_interface_vlan.this["vlan10"].vlan_id == 10
    error_message = "VLAN ID should be 10"
  }
  
  assert {
    condition     = routeros_interface_vlan.this["vlan10"].interface == "bridge1"
    error_message = "VLAN should be on bridge1"
  }
}

# Test 3: Bridge with ports
run "bridge_with_ports" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        comment = "Main bridge"
      }
    }
    bridge_ports = {
      "ether1-bridge" = {
        bridge    = "bridge1"
        interface = "ether1"
      }
      "ether2-bridge" = {
        bridge    = "bridge1"
        interface = "ether2"
      }
    }
  }
  
  assert {
    condition     = length(routeros_interface_bridge_port.this) == 2
    error_message = "Should have 2 bridge ports"
  }
  
  assert {
    condition     = routeros_interface_bridge_port.this["ether1-bridge"].bridge == "bridge1"
    error_message = "Port should be on bridge1"
  }
}

# Test 4: Bonding interface (802.3ad)
run "bonding_lacp" {
  command = plan
  
  variables {
    bonding_interfaces = {
      "bond0" = {
        mode   = "802.3ad"
        slaves = ["ether1", "ether2"]
        comment = "LACP bond"
      }
    }
  }
  
  assert {
    condition     = routeros_interface_bonding.this["bond0"].name == "bond0"
    error_message = "Bonding name should match key"
  }
  
  assert {
    condition     = routeros_interface_bonding.this["bond0"].mode == "802.3ad"
    error_message = "Bonding mode should be 802.3ad"
  }
  
  assert {
    condition     = length(routeros_interface_bonding.this["bond0"].slaves) == 2
    error_message = "Should have 2 slave interfaces"
  }
}

# Test 5: Interface list
run "interface_list" {
  command = plan
  
  variables {
    interface_lists = {
      "WAN" = {
        comment = "WAN interfaces"
      }
    }
    interface_list_members = {
      "ether1-wan" = {
        list      = "WAN"
        interface = "ether1"
      }
    }
  }
  
  assert {
    condition     = routeros_interface_list.this["WAN"].name == "WAN"
    error_message = "Interface list name should match key"
  }
  
  assert {
    condition     = routeros_interface_list_member.this["ether1-wan"].list == "WAN"
    error_message = "Interface should be member of WAN list"
  }
}

# Test 6: Ethernet interface (speed/duplex)
run "ethernet_interface" {
  command = plan
  
  variables {
    ethernet_interfaces = {
      "ether1" = {
        speed  = "1Gbps"
        duplex = "full"
        comment = "WAN interface"
      }
    }
  }
  
  assert {
    condition     = routeros_interface_ethernet.this["ether1"].speed == "1Gbps"
    error_message = "Ethernet speed should be 1Gbps"
  }
  
  assert {
    condition     = routeros_interface_ethernet.this["ether1"].full_duplex == true
    error_message = "Ethernet should be full duplex"
  }
}
