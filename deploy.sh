#!/usr/bin/env bash
set -e

# ── NIXOS DEPLOYMENT SCRIPT ───────────────────────────────────────────────────
# Standardized script to format, build, and apply configuration changes.
# Uses 'nh' (Nix Helper) for a cleaner CLI experience and visual diffs.

# --- Helper Functions ---
info() { echo -e "\n\033[1;34m[ INFO ]\033[0m $1"; }
ok()   { echo -e "\033[1;32m[ OK ]\033[0m $1"; }
err()  { echo -e "\033[1;31m[ ERR ]\033[0m $1"; exit 1; }

# --- Requirements ---
command -v nh >/dev/null 2>&1 || err "'nh' is not installed. Please install it or use nixos-rebuild manually."
command -v alejandra >/dev/null 2>&1 || info "Warning: 'alejandra' not found, skipping auto-format."

# --- Discovery ---
HOSTNAME=$(hostname)
[[ "$HOSTNAME" =~ ^(aorus|surface)$ ]] || info "Warning: Current hostname ($HOSTNAME) not explicitly defined in hosts/."

# --- Execution ---
info "Formatting Nix files..."
if command -v alejandra >/dev/null 2>&1; then
	alejandra . > /dev/null 2>&1
	ok "Code formatted with Alejandra."
fi

info "Adding changes to Git stage (required for flakes)..."
git add .
ok "Staged all changes."

info "Building and switching to new configuration (#$HOSTNAME)..."
if nh os switch . -- --accept-flake-config; then
	ok "Deployment successful!"
else
	err "Deployment failed. Check the logs above."
fi

# --- Summary ---
info "Deployment complete. Current generation:"
nixos-rebuild list-generations | grep current | awk '{print "  " $0}'
