provider "aci" {
  username    = var.aciUser
  private_key = var.aciPrivateKey
  cert_name   = var.aciCertName
  insecure    = true
  url         = var.aciUrl
}

resource "aci_tenant" "demo" {
  name        = var.tenantName
  description = "automated by terraform"
}

resource "aci_vrf" "vrf1" {
  tenant_dn = aci_tenant.demo.id
  name      = "vrf1"
}

resource "aci_bridge_domain" "bd" {
  tenant_dn          = aci_tenant.demo.id
  relation_fv_rs_ctx = aci_vrf.vrf1.name
  name               = "bd1"
}

resource "aci_application_profile" "app1" {
  tenant_dn = aci_tenant.demo.id
  name      = "app1"
}

data "aci_vmm_domain" "vds" {
  provider_profile_dn = var.provider_profile_dn
  name                = var.vmmDomain
}

resource "aci_application_epg" "epg" {
  count                  = var.epgCount
  application_profile_dn = aci_application_profile.app1.id
  name                   = "epg-${count.index}"
  relation_fv_rs_bd      = aci_bridge_domain.bd.name
  relation_fv_rs_dom_att = [data.aci_vmm_domain.vds.id]
  relation_fv_rs_cons    = [aci_contract.contract_epg1_epg2.name]
}

resource "aci_contract" "contract_epg1_epg2" {
  tenant_dn = aci_tenant.demo.id
  name      = "Web"
}

resource "aci_contract_subject" "Web_subject1" {
  contract_dn                  = aci_contract.contract_epg1_epg2.id
  name                         = "Subject"
  relation_vz_rs_subj_filt_att = [aci_filter.allow_https.name, aci_filter.allow_icmp.name]
}

resource "aci_filter" "allow_https" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_https"
}

resource "aci_filter" "allow_icmp" {
  tenant_dn = aci_tenant.demo.id
  name      = "allow_icmp"
}

resource "aci_filter_entry" "https" {
  name        = "https"
  filter_dn   = aci_filter.allow_https.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "https"
  d_to_port   = "https"
  stateful    = "yes"
}

resource "aci_filter_entry" "icmp" {
  name      = "icmp"
  filter_dn = aci_filter.allow_icmp.id
  ether_t   = "ip"
  prot      = "icmp"
  stateful  = "yes"
}

