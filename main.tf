variable login_approle_role_id {}
variable login_approle_secret_id {}
variable vault_url {}

provider "vault" {
  address = var.vault_url
  namespace = "admin/dev"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.login_approle_role_id
      secret_id = var.login_approle_secret_id
    }
  }
}

data "vault_kv_secret_v2" "kv2" {
  mount = "kv"
  name  = "my-secret"
}

output "secret_data" {
  value = data.vault_kv_secret_v2.kv2
  sensitive = true
}
