# vault-tf-approle-testing
Testing getting a secret from HCP Vault using terraform

## Setup Vault
For this guide I am using [HCP Vault](https://www.hashicorp.com/products/vaul), you can get started using this [guide](https://developer.hashicorp.com/vault/tutorials/cloud/get-started-vault)

Next we'll setup our approle and a simple KV which we will retrieve later using Terrafrom.

**login**
> **_NOTE:_**  Its recomended for production Vault clusters not to use the root token. In this setup we are using the root token and envrioment variables for ease, however if a production cluster use whatever method you nomraly use to access Vault. 
Via the HCP dashboard get the public URL and the root token and replace the in the following commands:

![URL](./docs/hcp-url.png)

![Token](./docs/hcp-token.png)

```bash
export VAULT_ADDR='https://**********:8200'
export VAULT_TOKEN="hvs.**********"

```

**configure namspace**
Next configure your namespace to be used later. 
> **_NOTE:_** `VAULT_NAMESPACE=admin` needs to be set if using HCP
```bash
export VAULT_NAMESPACE=admin
vault namespace create dev
export VAULT_NAMESPACE=admin/dev
```

**create kv**
Now lets create a simple KV2 moiunt in the new dev namespace and add a secret to it
```bash
vault secrets enable -namespace=admin/dev -version=2 kv
vault kv put -namespace=admin/dev -mount=kv my-secret foo=a bar=b
```

**configure policy**
Now lets add a policy we can use to access any secrets in that mount
```bash
vault policy write -namespace=admin/dev tf-kv tf-kv.hcl
```

**Setup AppRole**
Now lets setup the approle with using the new policy
```bash
vault auth enable -namespace=admin/dev approle

vault write -namespace=admin/dev auth/approle/role/my-role \
    secret_id_ttl=0 \
    token_ttl=20m \
    token_max_ttl=30m \
    token_policies=default,tf-kv

vault read -namespace=admin/dev auth/approle/role/my-role
```

**Get App role**
Below we will get our approle `role_id` and `secret_id`, note these down as we will use them later
```bash
vault read -namespace=admin/dev auth/approle/role/my-role/role-id
vault write -namespace=admin/dev -f auth/approle/role/my-role/secret-id
```

**test Login**
Now lets login using that approle and test we can get the KV
```bash
unset VAULT_TOKEN
unset VAULT_NAMESPACE
vault write -namespace=admin/dev auth/approle/login \
    role_id=******** \
    secret_id=******
```

This will output somerthing similar to the following, copy the token to use in the next step:
```
Key                     Value
---                     -----
token                   hvb.AAAAAQJ8MIwEELB3ucD61Wi8TILD******
token_accessor          n/a
token_duration          20m
token_renewable         false
token_policies          ["default" "tf-kv"]
identity_policies       []
policies                ["default" "tf-kv"]
token_meta_role_name    my-role
```

Now lets test a secret using the token from the previous command
```bash
export VAULT_TOKEN="hvb.AAAAAQJ8MIwEELB3ucD61Wi8TILD******"
vault kv get -namespace=admin/dev -mount=kv my-secret
```