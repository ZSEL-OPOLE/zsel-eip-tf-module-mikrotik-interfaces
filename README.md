# Terraform MikroTik Interfaces Module

Universal interface management module for MikroTik RouterOS devices (v7.16+).

## Features

- ✅ **Bridge Interfaces** - L2 switching with VLAN filtering
- ✅ **Bridge Ports** - Physical port assignment with PVID
- ✅ **VLAN Interfaces** - L3 gateway interfaces (802.1Q)
- ✅ **Interface Lists** - Logical grouping for firewall rules
- ✅ **Bonding (LACP)** - Link aggregation (802.3ad, active-backup, etc.)
- ✅ **Ethernet Settings** - Speed, duplex, MTU per physical port

## Usage Examples

### Basic Bridge + VLANs

```hcl
module "interfaces" {
  source = "./modules/mikrotik/interfaces"
  
  bridges = {
    "bridge-lan" = {
      vlan_filtering = true
      igmp_snooping  = true
      fast_forward   = true
      comment        = "Main LAN Bridge"
    }
  }
  
  bridge_ports = {
    "ether2-lan" = {
      bridge    = "bridge-lan"
      interface = "ether2"
      pvid      = 10
      comment   = "Access port VLAN 10"
    }
    "ether3-guest" = {
      bridge    = "bridge-lan"
      interface = "ether3"
      pvid      = 20
      comment   = "Guest WiFi VLAN 20"
    }
  }
  
  vlans = {
    "10" = {
      name      = "vlan10-management"
      interface = "bridge-lan"
      comment   = "Management VLAN"
    }
    "20" = {
      name      = "vlan20-guest"
      interface = "bridge-lan"
      comment   = "Guest WiFi VLAN"
    }
  }
  
  interface_lists = {
    "WAN" = {
      interfaces = ["ether1"]
      comment    = "Internet-facing"
    }
    "LAN" = {
      interfaces = ["bridge-lan", "vlan10-management", "vlan20-guest"]
      comment    = "Internal networks"
    }
  }
}
```

### Enterprise VLAN Configuration (46 VLANs)

```hcl
module "interfaces" {
  source = "./modules/mikrotik/interfaces"
  
  bridges = {
    "bridge-core" = {
      vlan_filtering = true
      igmp_snooping  = true
      fast_forward   = true
      mtu            = "9000"  # Jumbo frames
      comment        = "Core Bridge ZSEL"
    }
  }
  
  # Trunk ports to aggregation switches
  bridge_ports = {
    "sfp-plus-1-trunk" = {
      bridge    = "bridge-core"
      interface = "sfp-sfpplus1"
      pvid      = 600  # Management VLAN
      edge      = "no"  # STP: not edge port
      comment   = "Trunk to CRS518-AGG-01"
    }
    "sfp-plus-2-trunk" = {
      bridge    = "bridge-core"
      interface = "sfp-sfpplus2"
      pvid      = 600
      edge      = "no"
      comment   = "Trunk to CRS518-AGG-02"
    }
  }
  
  # 46 VLAN interfaces
  vlans = {
    # Dydaktyka (4 VLANs)
    "101" = { interface = "bridge-core", comment = "Dydaktyka P0" }
    "102" = { interface = "bridge-core", comment = "Dydaktyka P1" }
    "103" = { interface = "bridge-core", comment = "Dydaktyka P2" }
    "104" = { interface = "bridge-core", comment = "Dydaktyka P3" }
    
    # K3s Management
    "110" = { interface = "bridge-core", comment = "K3s Management" }
    
    # Labs (18 VLANs)
    "208" = { interface = "bridge-core", comment = "Lab BCU A" }
    "209" = { interface = "bridge-core", comment = "Lab BCU B" }
    # ... (remaining labs)
    
    # WiFi (4 VLANs)
    "300" = { interface = "bridge-core", comment = "WiFi P0" }
    "301" = { interface = "bridge-core", comment = "WiFi P1" }
    "302" = { interface = "bridge-core", comment = "WiFi P2" }
    "303" = { interface = "bridge-core", comment = "WiFi P3" }
    
    # Servers (12 VLANs)
    "400" = { interface = "bridge-core", comment = "Serwery Studenckie OLD" }
    "410" = { interface = "bridge-core", comment = "Serwery Studenckie DEV" }
    "411" = { interface = "bridge-core", comment = "Serwery Studenckie PROD" }
    
    # Admin + CCTV
    "500" = { interface = "bridge-core", comment = "Admin" }
    "501" = { interface = "bridge-core", comment = "CCTV" }
    
    # Management
    "600" = { interface = "bridge-core", comment = "Management" }
    
    # K3s Environments (25 VLANs)
    "701" = { interface = "bridge-core", comment = "K3s DEV Nodes 01" }
    "702" = { interface = "bridge-core", comment = "K3s DEV Nodes 02" }
    # ... (remaining K3s VLANs)
  }
  
  interface_lists = {
    "WAN" = {
      interfaces = ["ether1", "ether2"]
      comment    = "Dual WAN"
    }
    "LAN-INTERNAL" = {
      interfaces = ["vlan600", "vlan500"]
      comment    = "Management + Admin"
    }
    "LAN-STUDENT" = {
      interfaces = ["vlan101", "vlan102", "vlan103", "vlan104"]
      comment    = "Student networks"
    }
    "LAN-K3S" = {
      interfaces = ["vlan110", "vlan701", "vlan702"]
      comment    = "Kubernetes cluster"
    }
  }
}
```

### Bonding (LACP) for High Availability

```hcl
module "interfaces" {
  source = "./modules/mikrotik/interfaces"
  
  # LACP bonding (802.3ad)
  bonding_interfaces = {
    "bond-uplink" = {
      mode                 = "802.3ad"
      slaves               = ["sfp-sfpplus1", "sfp-sfpplus2"]
      transmit_hash_policy = "layer-2-and-3"
      lacp_rate            = "1sec"  # Fast LACP
      mtu                  = "9000"
      comment              = "LACP to Core Switch (20 Gbps)"
    }
  }
  
  # Bridge on top of bonding
  bridges = {
    "bridge-lan" = {
      vlan_filtering = true
      comment        = "LAN Bridge over LACP"
    }
  }
  
  bridge_ports = {
    "bond-to-bridge" = {
      bridge    = "bridge-lan"
      interface = "bond-uplink"
      pvid      = 1
      comment   = "Bonded uplink"
    }
  }
}
```

### Active-Backup Bonding (No LACP support)

```hcl
module "interfaces" {
  source = "./modules/mikrotik/interfaces"
  
  bonding_interfaces = {
    "bond-failover" = {
      mode     = "active-backup"
      slaves   = ["ether1", "ether2"]
      comment  = "WAN failover (no LACP)"
    }
  }
  
  interface_lists = {
    "WAN" = {
      interfaces = ["bond-failover"]
      comment    = "Bonded WAN"
    }
  }
}
```

### Physical Ethernet Settings (Force Speed/Duplex)

```hcl
module "interfaces" {
  source = "./modules/mikrotik/interfaces"
  
  ethernet_settings = {
    "ether1" = {
      speed            = "1G"
      duplex           = "full"
      auto_negotiation = false  # Force 1G full-duplex
      mtu              = 1500
      comment          = "WAN to ISP"
    }
    "sfp-sfpplus1" = {
      speed            = "10G"
      duplex           = "full"
      auto_negotiation = true
      mtu              = 9000
      comment          = "10G uplink to core"
    }
  }
}
```

### Multi-Bridge (Isolated Networks)

```hcl
module "interfaces" {
  source = "./modules/mikrotik/interfaces"
  
  bridges = {
    "bridge-lan" = {
      vlan_filtering = true
      comment        = "Main LAN"
    }
    "bridge-dmz" = {
      vlan_filtering = false
      comment        = "DMZ (isolated)"
    }
    "bridge-guest" = {
      vlan_filtering = false
      comment        = "Guest WiFi (isolated)"
    }
  }
  
  bridge_ports = {
    "ether2-lan" = {
      bridge    = "bridge-lan"
      interface = "ether2"
      pvid      = 10
    }
    "ether3-dmz" = {
      bridge    = "bridge-dmz"
      interface = "ether3"
      pvid      = 1
      horizon   = "1"  # Split horizon isolation
    }
    "ether4-guest" = {
      bridge    = "bridge-guest"
      interface = "ether4"
      pvid      = 1
      horizon   = "2"
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| mikrotik | ~> 1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bridges | Bridge interfaces | `map(object)` | `{}` | no |
| bridge_ports | Physical ports → bridge | `map(object)` | `{}` | no |
| vlans | VLAN interfaces (L3) | `map(object)` | `{}` | no |
| interface_lists | Interface grouping | `map(object)` | `{}` | no |
| bonding_interfaces | Link aggregation | `map(object)` | `{}` | no |
| ethernet_settings | Physical port settings | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bridges | Created bridges |
| bridge_ports | Bridge port assignments |
| vlans | Created VLAN interfaces |
| vlan_names | VLAN ID → name map |
| interface_lists | Created interface lists |
| interface_list_members | List memberships |
| bonding_interfaces | Created bonding interfaces |
| ethernet_settings | Ethernet configurations |
| all_interfaces | All managed interface names |
| vlan_count | Total VLANs configured |
| bridge_count | Total bridges configured |

## Validation Rules

- **PVID**: 1-4094 (IEEE 802.1Q standard)
- **VLAN IDs**: 1-4094 (map keys must be valid VLAN IDs)
- **MTU**: 64-9216 bytes
- **Bonding modes**: 802.3ad, balance-rr, active-backup, balance-xor, broadcast, balance-tlb, balance-alb
- **Bonding slaves**: At least 1 interface
- **Interface lists**: At least 1 interface per list

## Notes

- **VLAN Filtering**: Enable on bridge for 802.1Q trunking
- **IGMP Snooping**: Enable for multicast optimization (IPTV, video streaming)
- **Fast Forward**: Enable for hardware offloading (wire-speed switching)
- **Edge Ports**: STP edge detection (`auto`, `yes`, `no`)
- **Split Horizon**: Isolate ports within same bridge (use different horizon numbers)
- **LACP Rate**: `1sec` for fast failover, `30secs` for standard
- **Transmit Hash**: `layer-2-and-3` for IP-based load balancing

## Testing

```bash
# Validate module
terraform validate

# Plan with test config
terraform plan -var-file="test.tfvars"

# Apply single bridge
terraform apply -target="module.interfaces.routeros_interface_bridge.this[\"bridge-test\"]"
```

## License

MIT
