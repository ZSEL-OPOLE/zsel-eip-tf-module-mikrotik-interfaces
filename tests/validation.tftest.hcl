# =============================================================================
# MikroTik Interfaces Module - Validation Tests
# =============================================================================

# Mock provider configuration for testing without real RouterOS device
mock_provider "routeros" {}

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
