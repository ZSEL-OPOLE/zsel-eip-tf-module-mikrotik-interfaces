output "bridges" {
  description = "Created bridge interfaces"
  value = {
    for k, v in routeros_interface_bridge.this :
    k => {
      name           = v.name
      vlan_filtering = v.vlan_filtering
      igmp_snooping  = v.igmp_snooping
    }
  }
}

output "bridge_ports" {
  description = "Bridge port assignments"
  value = {
    for k, v in routeros_interface_bridge_port.this :
    k => {
      interface = v.interface
      bridge    = v.bridge
      pvid      = v.pvid
    }
  }
}

output "vlans" {
  description = "Created VLAN interfaces"
  value = {
    for k, v in routeros_interface_vlan.this :
    k => {
      name      = v.name
      vlan_id   = v.vlan_id
      interface = v.interface
    }
  }
}

output "vlan_names" {
  description = "Map of VLAN ID to interface name"
  value = {
    for k, v in routeros_interface_vlan.this :
    v.vlan_id => v.name
  }
}

output "interface_lists" {
  description = "Created interface lists"
  value = {
    for k, v in routeros_interface_list.this :
    k => {
      name    = v.name
      comment = v.comment
    }
  }
}

output "interface_list_members" {
  description = "Interface list memberships"
  value = {
    for k, v in routeros_interface_list_member.this :
    k => {
      list      = v.list
      interface = v.interface
    }
  }
}

output "bonding_interfaces" {
  description = "Created bonding interfaces"
  value = {
    for k, v in routeros_interface_bonding.this :
    k => {
      name   = v.name
      mode   = v.mode
      slaves = v.slaves
    }
  }
}

# Ethernet settings not supported by terraform-routeros/routeros provider
# Physical ethernet configuration must be done via RouterOS CLI/WinBox
# output "ethernet_settings" {
#   description = "Configured ethernet interfaces"
#   value = {
#     for k, v in routeros_interface_ethernet.this :
#     k => {
#       name   = v.name
#       speed  = v.speed
#       duplex = v.duplex
#       mtu    = v.mtu
#     }
#   }
# }

# Aggregated outputs for easy consumption
output "all_interfaces" {
  description = "All managed interface names"
  value = concat(
    keys(routeros_interface_bridge.this),
    keys(routeros_interface_vlan.this),
    keys(routeros_interface_bonding.this)
  )
}

output "vlan_count" {
  description = "Total number of VLANs configured"
  value       = length(routeros_interface_vlan.this)
}

output "bridge_count" {
  description = "Total number of bridges configured"
  value       = length(routeros_interface_bridge.this)
}
