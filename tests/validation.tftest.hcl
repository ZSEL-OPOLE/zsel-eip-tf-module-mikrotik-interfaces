# =============================================================================
# MikroTik Interfaces Module - Validation Tests
# =============================================================================

# Test 1: Invalid PVID (out of range 1-4094)
run "invalid_pvid_too_high" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        pvid = 5000  # Invalid - must be 1-4094
      }
    }
  }
  
  expect_failures = [
    var.bridges
  ]
}

# Test 2: Invalid PVID (zero)
run "invalid_pvid_zero" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        pvid = 0  # Invalid - must be >= 1
      }
    }
  }
  
  expect_failures = [
    var.bridges
  ]
}

# Test 3: Invalid MTU (too small)
run "invalid_mtu_too_small" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        mtu = 50  # Invalid - must be >= 64
      }
    }
  }
  
  expect_failures = [
    var.bridges
  ]
}

# Test 4: Invalid MTU (too large)
run "invalid_mtu_too_large" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        mtu = 10000  # Invalid - must be <= 9216
      }
    }
  }
  
  expect_failures = [
    var.bridges
  ]
}

# Test 5: Invalid VLAN ID in vlans
run "invalid_vlan_id" {
  command = plan
  
  variables {
    vlans = {
      "vlan5000" = {
        vlan_id   = 5000  # Invalid - must be 1-4094
        interface = "bridge1"
      }
    }
  }
  
  expect_failures = [
    var.vlans
  ]
}

# Test 6: Invalid bonding mode
run "invalid_bonding_mode" {
  command = plan
  
  variables {
    bonding_interfaces = {
      "bond1" = {
        mode   = "invalid-mode"  # Invalid
        slaves = ["ether1", "ether2"]
      }
    }
  }
  
  expect_failures = [
    var.bonding_interfaces
  ]
}

# Test 7: Valid PVID (boundary value 1)
run "valid_pvid_min" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        pvid = 1
      }
    }
  }
  
  assert {
    condition     = var.bridges["bridge1"].pvid == 1
    error_message = "Should accept PVID 1 (minimum)"
  }
}

# Test 8: Valid PVID (boundary value 4094)
run "valid_pvid_max" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        pvid = 4094
      }
    }
  }
  
  assert {
    condition     = var.bridges["bridge1"].pvid == 4094
    error_message = "Should accept PVID 4094 (maximum)"
  }
}

# Test 9: Valid MTU (minimum)
run "valid_mtu_min" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        mtu = 64
      }
    }
  }
  
  assert {
    condition     = var.bridges["bridge1"].mtu == 64
    error_message = "Should accept MTU 64 (minimum)"
  }
}

# Test 10: Valid MTU (maximum)
run "valid_mtu_max" {
  command = plan
  
  variables {
    bridges = {
      "bridge1" = {
        mtu = 9216
      }
    }
  }
  
  assert {
    condition     = var.bridges["bridge1"].mtu == 9216
    error_message = "Should accept MTU 9216 (maximum)"
  }
}
