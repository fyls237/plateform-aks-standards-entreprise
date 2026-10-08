# Disk Encryption Set module

Creates a customer-managed Key Vault key, an Azure Disk Encryption Set, and
the least-privilege RBAC assignment required for the Disk Encryption Set to
use the key.

The module creates an `RSA-HSM` key and requires an explicit RFC3339
`key_expiration_date` for regulated-environment key governance.

The Key Vault must have soft delete and purge protection enabled. The caller
must provide a Key Vault resource ID and ensure the Azure Key Vault provider
is registered in the subscription.
