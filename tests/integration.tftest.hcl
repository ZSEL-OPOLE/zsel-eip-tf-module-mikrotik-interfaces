# =============================================================================
# MikroTik Interfaces Module - Integration Tests
# =============================================================================

# Mock provider configuration for testing without real RouterOS device
mock_provider "routeros" {}

# Test 1: Complete network setup (bridge + VLANs + ports)
run "complete_network_setup" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        vlan_filtering = true
        igmp_snooping  = true
        mtu            = 1500
        comment        = "Main bridge with VLAN filtering"
      }
    }
    
    bridge_ports = {
      "ether2" = { bridge = "bridge1", interface = "ether2", pvid = 10 }
      "ether3" = { bridge = "bridge1", interface = "ether3", pvid = 20 }
      "ether4" = { bridge = "bridge1", interface = "ether4", pvid = 30 }
    }
    
    vlans = {
      "vlan10" = { vlan_id = 10, interface = "bridge1", comment = "Management" }
      "vlan20" = { vlan_id = 20, interface = "bridge1", comment = "Users" }
      "vlan30" = { vlan_id = 30, interface = "bridge1", comment = "Guest" }
    }
  }
  
  assert {
    condition     = routeros_interface_bridge.this["bridge1"].vlan_filtering == true
    error_message = "Bridge should have VLAN filtering enabled"
  }
  
  assert {
    condition     = length(routeros_interface_bridge_port.this) == 3
    error_message = "Should have 3 bridge ports"
  }
  
  assert {
    condition     = length(routeros_interface_vlan.this) == 3
    error_message = "Should have 3 VLAN interfaces"
  }
  
  assert {
    condition     = output.vlan_count == 3
    error_message = "Output vlan_count should be 3"
  }
}

# Test 2: Enterprise setup (46 VLANs - ZSEL example)
run "enterprise_46_vlans" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        vlan_filtering = true
        igmp_snooping  = true
        mtu            = 1500
      }
    }
    
    vlans = {
      "vlan10"  = { vlan_id = 10,  interface = "bridge1", comment = "K3s Cluster" }
      "vlan20"  = { vlan_id = 20,  interface = "bridge1", comment = "Storage" }
      "vlan30"  = { vlan_id = 30,  interface = "bridge1", comment = "LoadBalancer" }
      "vlan40"  = { vlan_id = 40,  interface = "bridge1", comment = "Endpoints" }
      "vlan50"  = { vlan_id = 50,  interface = "bridge1", comment = "VPN" }
      "vlan100" = { vlan_id = 100, interface = "bridge1", comment = "WiFi 1a" }
      "vlan101" = { vlan_id = 101, interface = "bridge1", comment = "WiFi 1b" }
      "vlan102" = { vlan_id = 102, interface = "bridge1", comment = "WiFi 1c" }
      "vlan103" = { vlan_id = 103, interface = "bridge1", comment = "WiFi 1d" }
      "vlan104" = { vlan_id = 104, interface = "bridge1", comment = "WiFi 1e" }
      # Add more VLANs as needed for full 46-VLAN test
    }
  }
  
  assert {
    condition     = length(routeros_interface_vlan.this) >= 10
    error_message = "Should have at least 10 VLANs in enterprise setup"
  }
}

# Test 3: LACP bonding with VLANs on top
run "lacp_with_vlans" {
  command = plan
  
  variables {
    bonding_interfaces = {
      "bond0" = {
        mode   = "802.3ad"
        slaves = ["ether1", "ether2"]
        mtu    = 1500
        comment = "LACP uplink"
      }
    }
    
    vlans = {
      "vlan10" = { vlan_id = 10, interface = "bond0", comment = "VLAN on bond" }
      "vlan20" = { vlan_id = 20, interface = "bond0", comment = "VLAN on bond" }
    }
  }
  
  assert {
    condition     = routeros_interface_bonding.this["bond0"].mode == "802.3ad"
    error_message = "Bonding should be LACP"
  }
  
  assert {
    condition     = routeros_interface_vlan.this["vlan10"].interface == "bond0"
    error_message = "VLAN should be on bonding interface"
  }
}

# Test 4: Interface lists for firewall
run "interface_lists_for_firewall" {
  command = plan
  
  variables {
    interface_lists = {
      "WAN"      = { comment = "WAN interfaces" }
      "LAN"      = { comment = "LAN interfaces" }
      "MGMT"     = { comment = "Management interfaces" }
    }
    
    interface_list_members = {
      "ether1-wan"    = { list = "WAN",  interface = "ether1" }
      "bridge1-lan"   = { list = "LAN",  interface = "bridge1" }
      "vlan600-mgmt"  = { list = "MGMT", interface = "vlan600" }
    }
  }
  
  assert {
    condition     = length(routeros_interface_list.this) == 3
    error_message = "Should have 3 interface lists"
  }
  
  assert {
    condition     = length(routeros_interface_list_member.this) == 3
    error_message = "Should have 3 list members"
  }
}

# Test 5: Outputs validation
run "outputs_comprehensive" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {}
      "bridge2" = {}
    }
    
    vlans = {
      "vlan10" = { vlan_id = 10, interface = "bridge1" }
      "vlan20" = { vlan_id = 20, interface = "bridge1" }
      "vlan30" = { vlan_id = 30, interface = "bridge1" }
    }
    
    bonding_interfaces = {
      "bond0" = { mode = "802.3ad", slaves = ["ether1", "ether2"] }
    }
  }
  
  assert {
    condition     = output.bridge_count == 2
    error_message = "Should output 2 bridges"
  }
  
  assert {
    condition     = output.vlan_count == 3
    error_message = "Should output 3 VLANs"
  }
  
  assert {
    condition     = output.bonding_count == 1
    error_message = "Should output 1 bonding interface"
  }
  
  assert {
    condition     = length(output.vlan_names) == 3
    error_message = "Should have 3 VLAN names in map"
  }
}
