locals {
  landing_site_dir_abs = var.landing_site_dir == null ? null : abspath(var.landing_site_dir)
  landing_site_files_base64_from_dir = var.landing_site_dir == null ? {} : {
    for rel in fileset(local.landing_site_dir_abs, "**") :
    rel => filebase64("${local.landing_site_dir_abs}/${rel}")
  }
  landing_site_files_base64_effective = length(var.landing_site_files_base64) > 0 ? var.landing_site_files_base64 : local.landing_site_files_base64_from_dir
}
