# Vault Terraform AppRole Testing

## Introduction
This guide demonstrates how to retrieve a secret from HashiCorp Vault hosted on HCP (HashiCorp Cloud Platform) using Terraform. We'll set up an AppRole and a simple KV (Key-Value) store in Vault, then use Terraform to access the secret.

## Setup Vault
In this guide, we're using HCP Vault. You can start with HCP Vault using this [guide](https://developer.hashicorp.com/vault/tutorials/cloud/get-started-vault).

First, let's configure Vault by setting environment variables for the Vault address and token.

```bash
export VAULT_ADDR='https://**********:8200'
export VAULT_TOKEN="hvs.**********"
```

### Configure Namespace
Configure the namespace to be used later. If using HCP, set `VAULT_NAMESPACE=admin`.

```bash
export VAULT_NAMESPACE=admin
vault namespace create dev
export VAULT_NAMESPACE=admin/dev
```

### Create KV
Now, create a simple KV version 2 mount in the `dev` namespace and add a secret to it.

```bash
vault secrets enable -namespace=admin/dev -version=2 kv
vault kv put -namespace=admin/dev -mount=kv my-secret foo=a bar=b
```

### Configure Policy
Add a policy to access any secrets in the mount.

```bash
vault policy write -namespace=admin/dev tf-kv tf-kv.hcl
```

### Setup AppRole
Setup the AppRole using the new policy.

```bash
vault auth enable -namespace=admin/dev approle

vault write -namespace=admin/dev auth/approle/role/my-role \
    secret_id_ttl=0 \
    token_ttl=20m \
    token_max_ttl=30m \
    token_policies=default,tf-kv

vault read -namespace=admin/dev auth/approle/role/my-role
```

### Get AppRole
Retrieve the AppRole `role_id` and `secret_id` for later use.

```bash
vault read -namespace=admin/dev auth/approle/role/my-role/role-id
vault write -namespace=admin/dev -f auth/approle/role/my-role/secret-id
```

### Test Login
Login using the AppRole and verify access to the KV store.

```bash
unset VAULT_TOKEN
unset VAULT_NAMESPACE
vault write -namespace=admin/dev auth/approle/login \
    role_id=******** \
    secret_id=******
```

The output will include a token. Copy this token for the next step.

Now, test retrieving a secret using the token obtained from the previous command.

```bash
export VAULT_TOKEN="hvb.AAAAAQJ8MIwEELB3ucD61Wi8TILD******"
vault kv get -namespace=admin/dev -mount=kv my-secret
```
