# =============================================================================
# MikroTik Interfaces Module - Validation Tests
# =============================================================================

# Mock provider configuration for testing without real RouterOS device
mock_provider "routeros" {}

# Test 1: Valid bridge configuration
run "valid_bridge" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        vlan_filtering = true
        igmp_snooping  = true
        mtu            = "1500"
      }
    }
  }
  
  assert {
    condition     = var.bridges["bridge1"].vlan_filtering == true
    error_message = "VLAN filtering should be enabled"
  }
}

# Test 2: Valid VLAN interface
run "valid_vlan" {
  command = plan
  
  variables {
    vlans = {
      "10" = {
        interface = "bridge1"
        comment   = "Management VLAN"
      }
    }
  }
  
  assert {
    condition     = var.vlans["10"].interface == "bridge1"
    error_message = "VLAN should be on bridge1"
  }
}

# Test 3: Valid bridge port with PVID
run "valid_bridge_port" {
  command = plan
  
  variables {
    bridge_ports = {
      "port1" = {
        bridge    = "bridge1"
        interface = "ether1"
        pvid      = 10
      }
    }
  }
  
  assert {
    condition     = var.bridge_ports["port1"].pvid == 10
    error_message = "PVID should be 10"
  }
}

# Test 4: Valid bonding interface
run "valid_bonding" {
  command = plan
  
  variables {
    bonding = {
      "bond1" = {
        mode   = "802.3ad"
        slaves = ["ether1", "ether2"]
      }
    }
  }
  
  assert {
    condition     = var.bonding["bond1"].mode == "802.3ad"
    error_message = "Bonding mode should be 802.3ad"
  }
}
