#!/bin/bash

#############################################
# bump_version.sh - Version Bump Script
#
# Auto-detects version bump based on conventional commits
# since the last tag, updates pubspec.yaml, and creates git tag.
#
# Usage:
#   ./scripts/bump_version.sh                 # Auto-detect bump type
#   ./scripts/bump_version.sh --patch         # Force PATCH bump
#   ./scripts/bump_version.sh --minor         # Force MINOR bump
#   ./scripts/bump_version.sh --major         # Force MAJOR bump
#   ./scripts/bump_version.sh --dry-run       # Preview without changes
#
# Commit Types → Version Bumps:
#   feat! or feat: + BREAKING CHANGE → MAJOR (x.0.0)
#   feat:                                 → MINOR (1.x.0)
#   fix:, refactor:, perf:                → PATCH (1.0.x)
#   docs:, test:, ci:, chore:, style:     → No bump
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
FORCE_BUMP=""

for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --patch|--minor|--major)
      FORCE_BUMP="${arg#--}"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --patch    Force PATCH version bump (1.0.x)"
      echo "  --minor    Force MINOR version bump (1.x.0)"
      echo "  --major    Force MAJOR version bump (x.0.0)"
      echo "  --dry-run  Preview changes without modifying files"
      echo "  -h, --help Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                    # Auto-detect bump type from commits"
      echo "  $0 --patch            # Force PATCH bump"
      echo "  $0 --dry-run          # Preview without changes"
      exit 0
      ;;
  esac
done

# Functions
log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_info_stderr() {
  echo -e "${BLUE}ℹ${NC} $1" >&2
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

# Check if working tree is clean
check_clean_tree() {
  if [ "$DRY_RUN" = true ]; then
    return 0
  fi

  if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    log_error "Working tree is not clean. Please commit or stash changes first."
    exit 1
  fi
}

# Get the latest tag
get_latest_tag() {
  local latest_tag
  latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  echo "$latest_tag"
}

# Get current version from pubspec.yaml
get_current_version() {
  local version
  version=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//' | tr -d '[:space:]')
  echo "$version"
}

# Validate semver format
validate_semver() {
  local version=$1
  if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_error "Invalid semver format: $version"
    exit 1
  fi
}

# Bump version based on type
bump_version() {
  local current_version=$1
  local bump_type=$2

  IFS='.' read -r major minor patch <<< "$current_version"

  case "$bump_type" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
    none)
      echo "$current_version"
      return
      ;;
  esac

  echo "${major}.${minor}.${patch}"
}

# Analyze commits to determine bump type
analyze_commits() {
  local latest_tag=$1
  local bump_type="none"

  # Get commits since latest tag (or all commits if no tag)
  if [ -z "$latest_tag" ]; then
    commits=$(git log --pretty=format:"%s" --reverse)
  else
    commits=$(git log "${latest_tag}..HEAD" --pretty=format:"%s" --reverse)
  fi

  if [ -z "$commits" ]; then
    log_warn "No commits found since ${latest_tag:-beginning}"
    echo "none"
    return
  fi

  # Count commit types
  feat_count=$(echo "$commits" | grep -cE "^feat" || true)
  fix_count=$(echo "$commits" | grep -cE "^(fix|refactor|perf):" || true)
  breaking_count=$(echo "$commits" | grep -cE "BREAKING CHANGE" || true)
  feat_bang_count=$(echo "$commits" | grep -cE "^feat!" || true)

  # Determine bump type based on priority
  if [ "$breaking_count" -gt 0 ] || [ "$feat_bang_count" -gt 0 ]; then
    bump_type="major"
  elif [ "$feat_count" -gt 0 ]; then
    bump_type="minor"
  elif [ "$fix_count" -gt 0 ]; then
    bump_type="patch"
  fi

  # Show analysis (to stderr to avoid capture)
  log_info_stderr "Analyzing commits since ${latest_tag:-beginning}..."
  echo "$commits" | head -20 >&2
  if [ $(echo "$commits" | wc -l) -gt 20 ]; then
    log_info_stderr "... and $(($(echo "$commits" | wc -l) - 20)) more commits"
  fi
  echo "" >&2
  log_info_stderr "Commit analysis:"
  [ "$feat_count" -gt 0 ] && echo "  - feat: $feat_count" >&2
  [ "$fix_count" -gt 0 ] && echo "  - fix/refactor/perf: $fix_count" >&2
  [ "$breaking_count" -gt 0 ] && echo "  - BREAKING CHANGE: $breaking_count" >&2
  [ "$feat_bang_count" -gt 0 ] && echo "  - feat!: $feat_bang_count" >&2

  echo "$bump_type"
}

# Update pubspec.yaml with new version
update_pubspec() {
  local new_version=$1
  local old_version=$2

  if [ "$DRY_RUN" = true ]; then
    log_info "[DRY RUN] Would update pubspec.yaml: $old_version → $new_version"
    return 0
  fi

  # Update version in pubspec.yaml (remove build number if present)
  sed -i "s/^version: $old_version.*/version: $new_version/" pubspec.yaml
  log_success "Updated pubspec.yaml: $old_version → $new_version"
}

# Create version commit and tag
create_commit_and_tag() {
  local new_version=$1

  if [ "$DRY_RUN" = true ]; then
    log_info "[DRY RUN] Would create commit: chore: bump version to $new_version"
    log_info "[DRY RUN] Would create tag: v$new_version"
    return 0
  fi

  # Create commit
  git add pubspec.yaml
  git commit -m "chore: bump version to $new_version"
  log_success "Created commit: chore: bump version to $new_version"

  # Create annotated tag
  git tag -a "v$new_version" -m "Release $new_version"
  log_success "Created tag: v$new_version"
}

# Check if tag already exists
check_tag_exists() {
  local tag=$1
  if git rev-parse "$tag" >/dev/null 2>&1; then
    log_error "Tag $tag already exists. Use --major/--minor/--patch to force a different version."
    exit 1
  fi
}

# Main execution
main() {
  log_info "=== Catat Cuan Version Bumper ==="
  echo ""

  # Check prerequisites
  check_clean_tree

  # Get current state
  latest_tag=$(get_latest_tag)
  current_version=$(get_current_version)

  log_info "Current version: $current_version"
  [ -n "$latest_tag" ] && log_info "Latest tag: $latest_tag" || log_info "No tags found"
  echo ""

  # Validate current version
  validate_semver "$current_version"

  # Determine bump type
  if [ -n "$FORCE_BUMP" ]; then
    bump_type="$FORCE_BUMP"
    log_info "Force $bump_type bump requested"
  else
    bump_type=$(analyze_commits "$latest_tag")
  fi
  echo ""

  if [ "$bump_type" = "none" ]; then
    log_warn "No version bump needed based on commit types"
    log_info "Use --patch, --minor, or --major to force a bump"
    exit 0
  fi

  # Calculate new version
  new_version=$(bump_version "$current_version" "$bump_type")

  log_info "Bumping version: $current_version → $new_version ($bump_type)"
  echo ""

  # Check if tag would already exist
  check_tag_exists "v$new_version"

  # Update pubspec.yaml
  update_pubspec "$new_version" "$current_version"

  # Create commit and tag
  create_commit_and_tag "$new_version"

  echo ""
  if [ "$DRY_RUN" = true ]; then
    log_info "[DRY RUN] Preview complete. No changes were made."
  else
    log_success "Version bump complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Review the commit: git log -1"
    echo "  2. Push to main: git push origin main"
    echo "  3. Push the tag: git push origin v$new_version"
    echo ""
    log_info "The release workflow will automatically:"
    echo "  - Build the APK"
    echo "  - Generate changelog"
    echo "  - Create GitHub Release"
  fi
}

# Run main
main
