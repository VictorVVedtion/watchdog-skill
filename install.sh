#!/usr/bin/env bash
set -euo pipefail

# Watchdog Skill Installer
# Usage: curl -fsSL <raw-url>/install.sh | bash
#   or:  ./install.sh [target-project-dir]

SKILL_NAME="watchdog"
REPO_URL="https://github.com/vvedition/watchdog-skill"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[watchdog]${NC} $1"; }
warn()  { echo -e "${YELLOW}[watchdog]${NC} $1"; }
error() { echo -e "${RED}[watchdog]${NC} $1" >&2; }

# Determine target directory
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

SKILL_DIR="$TARGET_DIR/.claude/skills/$SKILL_NAME"

# Pre-flight checks
check_deps() {
    local required_missing=()
    local recommended_missing=()

    # Required dependencies
    if ! command -v git &>/dev/null; then
        required_missing+=("git (required - core signal collection)")
    fi

    # Optional dependencies (Deep Mode only)
    if ! command -v gemini &>/dev/null && ! command -v codex &>/dev/null; then
        recommended_missing+=("gemini or codex (optional - needed only for --deep mode, Quick Mode works without)")
    fi

    if ! command -v jq &>/dev/null; then
        recommended_missing+=("jq (recommended - JSON state file management, Claude can handle as fallback)")
    fi

    if [ ${#required_missing[@]} -gt 0 ]; then
        error "Missing required dependencies:"
        for dep in "${required_missing[@]}"; do
            echo "  - $dep"
        done
        echo ""
        error "Please install required dependencies before using Watchdog."
        echo ""
    fi

    if [ ${#recommended_missing[@]} -gt 0 ]; then
        warn "Missing recommended dependencies:"
        for dep in "${recommended_missing[@]}"; do
            echo "  - $dep"
        done
        echo ""
        warn "Watchdog will install but some features may be limited."
        echo ""
    fi

    # Ralph Skill detection (optional enhancer)
    if [ -d "$TARGET_DIR/.claude/skills/ralph" ] || [ -f "$TARGET_DIR/.claude/ralph-loop.local.md" ]; then
        info "Ralph Skill detected - auto mode will use Ralph's iteration loop for signal enhancement"
    else
        info "Ralph Skill not detected - all features work fine, auto mode uses passive triggering"
    fi
}

# Determine source directory (local clone or script location)
get_source_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -f "$script_dir/CLAUDE.md" ] && [ -f "$script_dir/SKILL.md" ]; then
        echo "$script_dir"
    else
        # Clone from GitHub
        local tmp_dir
        tmp_dir="$(mktemp -d)"
        info "Cloning from $REPO_URL..."
        git clone --depth 1 "$REPO_URL" "$tmp_dir" 2>/dev/null
        echo "$tmp_dir"
    fi
}

install_skill() {
    local source_dir="$1"

    info "Installing Watchdog Skill to: $SKILL_DIR"

    # Create skill directory
    mkdir -p "$SKILL_DIR/modules"

    # Copy core files
    cp "$source_dir/SKILL.md" "$SKILL_DIR/"

    # Copy all module files
    for module_file in "$source_dir/modules/"*.md; do
        if [ -f "$module_file" ]; then
            cp "$module_file" "$SKILL_DIR/modules/"
            info "  Copied module: $(basename "$module_file")"
        fi
    done

    # Append CLAUDE.md instructions to project CLAUDE.md
    local project_claude="$TARGET_DIR/CLAUDE.md"
    local skill_claude="$source_dir/CLAUDE.md"

    if [ -f "$project_claude" ]; then
        if grep -q "Watchdog Skill" "$project_claude" 2>/dev/null; then
            warn "Watchdog instructions already in CLAUDE.md, skipping append."
        else
            echo "" >> "$project_claude"
            echo "<!-- BEGIN WATCHDOG SKILL -->" >> "$project_claude"
            cat "$skill_claude" >> "$project_claude"
            echo "<!-- END WATCHDOG SKILL -->" >> "$project_claude"
            info "Appended Watchdog instructions to existing CLAUDE.md"
        fi
    else
        cp "$skill_claude" "$project_claude"
        info "Created CLAUDE.md with Watchdog instructions"
    fi

    # Create .claude directory if needed
    mkdir -p "$TARGET_DIR/.claude"

    # Auto-append runtime files to .gitignore
    local gitignore="$TARGET_DIR/.gitignore"
    local watchdog_entries=(
        ".claude/watchdog.local.json"
        ".claude/watchdog.log"
    )

    if [ -f "$gitignore" ]; then
        for entry in "${watchdog_entries[@]}"; do
            if ! grep -qF "$entry" "$gitignore" 2>/dev/null; then
                echo "$entry" >> "$gitignore"
                info "  Added $entry to .gitignore"
            fi
        done
    else
        printf '%s\n' "${watchdog_entries[@]}" > "$gitignore"
        info "Created .gitignore with Watchdog runtime files"
    fi

    info "Installation complete!"
    echo ""
    echo "  Usage:"
    echo "    /watchdog              # Quick sniff (barks if not healthy)"
    echo "    /watchdog --ground on  # Activate proactive grounding"
    echo "    /watchdog --deep       # Full vet checkup (external AI)"
    echo "    /watchdog --auto       # Guard duty (auto-patrol)"
    echo "    /watchdog --report     # Full report with trends"
    echo "    /watchdog --status     # Is the dog awake?"
    echo "    /watchdog --reset      # Fresh start"
    echo ""
}

uninstall_skill() {
    info "Uninstalling Watchdog Skill from: $TARGET_DIR"

    # Remove skill directory
    if [ -d "$SKILL_DIR" ]; then
        rm -rf "$SKILL_DIR"
        info "Removed skill directory: $SKILL_DIR"
    fi

    # Remove CLAUDE.md section
    local project_claude="$TARGET_DIR/CLAUDE.md"
    if [ -f "$project_claude" ] && grep -q "BEGIN WATCHDOG SKILL" "$project_claude" 2>/dev/null; then
        sed -i '' '/<!-- BEGIN WATCHDOG SKILL -->/,/<!-- END WATCHDOG SKILL -->/d' "$project_claude" 2>/dev/null || \
        sed -i '/<!-- BEGIN WATCHDOG SKILL -->/,/<!-- END WATCHDOG SKILL -->/d' "$project_claude" 2>/dev/null
        info "Removed Watchdog section from CLAUDE.md"
    fi

    # Remove runtime files
    rm -f "$TARGET_DIR/.claude/watchdog.local.json"
    rm -f "$TARGET_DIR/.claude/watchdog.log"
    info "Removed runtime files"

    info "Uninstall complete!"
}

main() {
    echo ""
    echo "  ==========================="
    echo "  Watchdog Skill v3.0.0"
    echo "  ==========================="
    echo ""

    # Handle --uninstall flag
    if [[ "${2:-}" == "--uninstall" ]] || [[ "${1:-}" == "--uninstall" ]]; then
        uninstall_skill
        return 0
    fi

    check_deps

    local source_dir
    source_dir="$(get_source_dir)"

    install_skill "$source_dir"

    # Cleanup temp dir if cloned
    if [[ "$source_dir" == /tmp/* ]] || [[ "$source_dir" == /private/tmp/* ]]; then
        rm -rf "$source_dir"
    fi
}

main "$@"
