# NixOS Configuration Commenting Rules

To maintain the "Strict Blocky" Oxocarbon aesthetic, all Nix files in this repository must follow these commenting standards.

## 1. Section Header (Major)
Used for primary logical blocks (Imports, OS configuration, User configuration).
- **Format**: `# ── SECTION NAME ─────────────────────────────────────────────────────────`
- **Width**: Exactly 80 characters total.

## 2. Sub-section Header (Minor)
Used for grouping related settings within a section.
- **Format**: `# --- Category Name ---`
- **Indentation**: Match the current block level.

## 3. Inline & Contextual Comments
Used for individual settings or specific logic.
- **Format**: `# Description or rationale`
- **Position**: Above the setting or on the same line if very short.

## 4. Visual Balance
- Leave exactly one blank line before a Section Header.
- No blank lines between a Sub-section Header and its first setting.
- Use whitespace to group related settings visually.
- Tabs for indentation.

---
*Follow these rules to ensure the configuration remains readable and professional.*
