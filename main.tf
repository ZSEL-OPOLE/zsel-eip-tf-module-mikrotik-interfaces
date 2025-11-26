# ===== BRIDGE INTERFACES =====
resource "routeros_interface_bridge" "this" {
  for_each = var.bridges
  
  name           = each.key
  vlan_filtering = lookup(each.value, "vlan_filtering", false)
  igmp_snooping  = lookup(each.value, "igmp_snooping", false)
  fast_forward   = lookup(each.value, "fast_forward", true)
  mtu            = lookup(each.value, "mtu", "auto")
  comment        = lookup(each.value, "comment", null)
  disabled       = lookup(each.value, "disabled", false)
}

# ===== BRIDGE PORTS =====
resource "routeros_interface_bridge_port" "this" {
  for_each = var.bridge_ports
  
  bridge    = each.value.bridge
  interface = each.value.interface
  pvid      = lookup(each.value, "pvid", 1)
  edge      = lookup(each.value, "edge", "auto")
  horizon   = lookup(each.value, "horizon", "none")
  comment   = lookup(each.value, "comment", null)
  disabled  = lookup(each.value, "disabled", false)
  
  depends_on = [routeros_interface_bridge.this]
}

# ===== VLAN INTERFACES =====
resource "routeros_interface_vlan" "this" {
  for_each = var.vlans
  
  name      = lookup(each.value, "name", "vlan${each.key}")
  vlan_id   = tonumber(each.key)
  interface = each.value.interface
  mtu       = lookup(each.value, "mtu", "auto")
  comment   = lookup(each.value, "comment", null)
  disabled  = lookup(each.value, "disabled", false)
  
  depends_on = [routeros_interface_bridge.this]
}

# ===== INTERFACE LISTS =====
resource "routeros_interface_list" "this" {
  for_each = var.interface_lists
  
  name    = each.key
  comment = lookup(each.value, "comment", null)
}

resource "routeros_interface_list_member" "this" {
  for_each = local.interface_list_members
  
  list      = each.value.list
  interface = each.value.interface
  
  depends_on = [
    routeros_interface_list.this,
    routeros_interface_vlan.this,
    routeros_interface_bridge.this
  ]
}

# ===== BONDING INTERFACES (LACP / Link Aggregation) =====
resource "routeros_interface_bonding" "this" {
  for_each = var.bonding_interfaces
  
  name             = each.key
  mode             = each.value.mode
  slaves           = each.value.slaves
  transmit_hash_policy = lookup(each.value, "transmit_hash_policy", "layer-2-and-3")
  lacp_rate        = lookup(each.value, "lacp_rate", "30secs")
  mtu              = lookup(each.value, "mtu", "auto")
  comment          = lookup(each.value, "comment", null)
  disabled         = lookup(each.value, "disabled", false)
}

# ===== PHYSICAL ETHERNET SETTINGS =====
# Note: routeros_interface_ethernet requires factory_name and doesn't support duplex
# Physical ethernet settings should be configured manually via RouterOS CLI/WinBox
# or use routeros_interface resource for basic settings
# resource "routeros_interface_ethernet" "this" {
#   for_each = var.ethernet_settings
#   
#   factory_name = each.key  # Required by provider
#   name         = each.key
#   # duplex not supported
#   # speed configuration may differ
# }
