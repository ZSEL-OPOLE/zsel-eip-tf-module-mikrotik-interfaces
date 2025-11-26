# ===== BRIDGES =====
variable "bridges" {
  description = "Bridge interfaces configuration"
  type = map(object({
    vlan_filtering = optional(bool, false)
    igmp_snooping  = optional(bool, false)
    fast_forward   = optional(bool, true)
    mtu            = optional(string, "auto")
    comment        = optional(string)
    disabled       = optional(bool, false)
  }))
  default = {}
}

# ===== BRIDGE PORTS =====
variable "bridge_ports" {
  description = "Physical interfaces to add to bridges"
  type = map(object({
    bridge    = string
    interface = string
    pvid      = optional(number, 1)
    edge      = optional(string, "auto")  # "auto", "yes", "no"
    horizon   = optional(string, "none")  # Split horizon (number or "none")
    comment   = optional(string)
    disabled  = optional(bool, false)
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.bridge_ports :
      v.pvid >= 1 && v.pvid <= 4094
    ])
    error_message = "PVID must be between 1 and 4094."
  }
}

# ===== VLAN INTERFACES =====
variable "vlans" {
  description = "VLAN interfaces (L3 gateways)"
  type = map(object({
    name      = optional(string)
    interface = string
    mtu       = optional(string, "auto")
    comment   = optional(string)
    disabled  = optional(bool, false)
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.vlans :
      can(tonumber(k)) && tonumber(k) >= 1 && tonumber(k) <= 4094
    ])
    error_message = "VLAN map keys must be valid VLAN IDs (1-4094)."
  }
}

# ===== INTERFACE LISTS =====
variable "interface_lists" {
  description = "Interface lists for firewall grouping"
  type = map(object({
    interfaces = list(string)
    comment    = optional(string)
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.interface_lists :
      length(v.interfaces) > 0
    ])
    error_message = "Each interface list must contain at least one interface."
  }
}

# ===== BONDING =====
variable "bonding_interfaces" {
  description = "Link aggregation (bonding) interfaces"
  type = map(object({
    mode                 = string           # "802.3ad", "balance-rr", "active-backup", "balance-xor"
    slaves               = list(string)     # Physical interfaces
    transmit_hash_policy = optional(string, "layer-2-and-3")  # "layer-2", "layer-2-and-3", "layer-3-and-4"
    lacp_rate            = optional(string, "30secs")          # "30secs", "1sec"
    mtu                  = optional(string, "auto")
    comment              = optional(string)
    disabled             = optional(bool, false)
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.bonding_interfaces :
      contains(["802.3ad", "balance-rr", "active-backup", "balance-xor", "broadcast", "balance-tlb", "balance-alb"], v.mode)
    ])
    error_message = "Bonding mode must be one of: 802.3ad, balance-rr, active-backup, balance-xor, broadcast, balance-tlb, balance-alb."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.bonding_interfaces :
      length(v.slaves) >= 1
    ])
    error_message = "Bonding interface must have at least one slave interface."
  }
}

# ===== ETHERNET SETTINGS =====
variable "ethernet_settings" {
  description = "Physical ethernet interface settings"
  type = map(object({
    speed            = optional(string, "auto")  # "auto", "10M", "100M", "1G", "10G", "25G", "40G", "100G"
    duplex           = optional(string, "auto")  # "auto", "half", "full"
    auto_negotiation = optional(bool, true)
    mtu              = optional(number, 1500)
    comment          = optional(string)
    disabled         = optional(bool, false)
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.ethernet_settings :
      v.mtu >= 64 && v.mtu <= 9216
    ])
    error_message = "MTU must be between 64 and 9216 bytes."
  }
}
