# 🔒 Secrets Management (`sops-nix`)

Sensitive payload variables (e.g., passwords, API keys, credentials) are securely stored and encrypted in this directory using `sops-nix` and `age` keys.

---

## 🔑 Key Structure

- **`master.pub`** - The main age public key of the primary system administrator.
- **`surface.pub`** - The public key corresponding to the Microsoft Surface Pro host.
- **`secrets.yaml`** - The encrypted SOPS payload, containing user password hashes and SSH/git configuration tokens.

---

## 🛠️ Workflows

### ✏️ Editing Secrets
Secrets are encrypted using YAML formats. Do not attempt to edit `secrets.yaml` directly with standard text editors as it will be fully encrypted. Instead, use the automated `just` task:

```bash
just secrets-edit
```

This will automatically:
1. Decrypt the secrets to a secure temporary system memory buffer.
2. Open your configured `$EDITOR` (or `nvim` as default) to let you safely edit the values.
3. Automatically re-encrypt the file with the correct public keys when you save and close the editor.

---

## 💻 Referencing Secrets in Nix Config

To reference decrypted secrets in your system modules:

1. Register the secret key inside the SOPS settings in `modules/core/sops.nix`:
   ```nix
   sops.secrets.my_api_key = {
     owner = "myuser";
     mode = "0400";
   };
   ```
2. Reference the generated dynamic decryption path within your target configuration:
   ```nix
   services.my-service.apiKeyFile = config.sops.secrets.my_api_key.path;
   ```

---

## ⚠️ Important Rules

> [!WARNING]
> - **Never** commit plaintext secrets to Git.
> - Always verify that `.gitignore` is correctly configured to ignore raw unencrypted outputs.
> - If you add a new public age key, remember to update `.sops.yaml` at the root of the project to ensure the files are encrypted with the new keys.
