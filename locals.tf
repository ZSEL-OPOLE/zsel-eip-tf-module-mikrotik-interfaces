# ===== INTERFACE LIST MEMBERS FLATTENING =====
# Transform nested interface_lists structure into flat map for resource creation
locals {
  interface_list_members = {
    for item in flatten([
      for list_name, list_config in var.interface_lists : [
        for iface in list_config.interfaces : {
          key       = "${list_name}--${iface}"  # Unique key
          list      = list_name
          interface = iface
        }
      ]
    ]) : item.key => item
  }
  
  # Bridge summary
  bridges_summary = {
    total       = length(var.bridges)
    vlan_aware  = length([for k, v in var.bridges : k if lookup(v, "vlan_filtering", false)])
    igmp_enabled = length([for k, v in var.bridges : k if lookup(v, "igmp_snooping", false)])
  }
  
  # VLAN summary
  vlans_summary = {
    total      = length(var.vlans)
    vlan_ids   = [for k, v in var.vlans : tonumber(k)]
    vlan_names = [for k, v in var.vlans : lookup(v, "name", "vlan${k}")]
  }
  
  # Bridge ports summary
  bridge_ports_summary = {
    total        = length(var.bridge_ports)
    by_bridge    = {
      for bridge in distinct([for k, v in var.bridge_ports : v.bridge]) :
      bridge => length([for k, v in var.bridge_ports : k if v.bridge == bridge])
    }
    access_ports = length([for k, v in var.bridge_ports : k if lookup(v, "pvid", 1) != 1])
  }
  
  # Bonding summary
  bonding_summary = {
    total        = length(var.bonding_interfaces)
    lacp_count   = length([for k, v in var.bonding_interfaces : k if v.mode == "802.3ad"])
    total_slaves = length(var.bonding_interfaces) > 0 ? sum([for k, v in var.bonding_interfaces : length(v.slaves)]) : 0
  }
  
  # Interface lists summary
  interface_lists_summary = {
    total             = length(var.interface_lists)
    total_memberships = length(local.interface_list_members)
    lists_by_size     = {
      for list_name, list_config in var.interface_lists :
      list_name => length(list_config.interfaces)
    }
  }
  
  # Module metadata
  module_info = {
    name    = "interfaces"
    version = "1.0.0"
    purpose = "Universal interface management for MikroTik RouterOS"
  }
}
