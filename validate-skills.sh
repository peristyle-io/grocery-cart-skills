#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SKILLS_DIR="skills"
ISSUES=0
WARNINGS=0
PASSED=0

echo "Validating Peristyle Cart Skills"
echo "================================="
echo ""

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"
    skill_errors=()
    skill_warnings=()

    if [[ ! -f "$skill_file" ]]; then
        echo -e "${RED}❌ $skill_name${NC}"
        echo "   Missing SKILL.md"
        ((ISSUES++))
        continue
    fi

    frontmatter=$(awk '/^---$/{count++; next} count==1' "$skill_file")

    if [[ -z "$frontmatter" ]]; then
        echo -e "${RED}❌ $skill_name${NC}"
        echo "   Missing YAML frontmatter (---)"
        ((ISSUES++))
        continue
    fi

    # name validation
    name_in_file=$(echo "$frontmatter" | grep "^name:" | sed 's/^name: *//' | tr -d ' ')
    if [[ -z "$name_in_file" ]]; then
        skill_errors+=("Missing 'name' field in frontmatter")
    elif [[ "$name_in_file" != "$skill_name" ]]; then
        skill_errors+=("Name mismatch: directory='$skill_name' but frontmatter='$name_in_file'")
    elif ! [[ "$name_in_file" =~ ^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$ ]]; then
        skill_errors+=("Invalid name format: '$name_in_file' (lowercase, alphanumeric + hyphens only)")
    fi

    # description validation
    description=$(echo "$frontmatter" | grep "^description:" | head -1 | sed 's/^description: *//')
    description="${description#\"}"
    description="${description%\"}"
    # handle multiline (>) by grabbing continuation lines
    if [[ -z "$description" ]] || [[ "$description" == ">" ]] || [[ "$description" == ">-" ]]; then
        description=$(awk '/^---$/{count++; next} count==1 && /^  /' "$skill_file" | tr -d '\n' | sed 's/^  *//')
    fi

    if [[ -z "$description" ]]; then
        skill_errors+=("Missing 'description' field in frontmatter")
    else
        desc_len=${#description}
        if [[ $desc_len -lt 1 || $desc_len -gt 1024 ]]; then
            skill_errors+=("Description length invalid: $desc_len chars (must be 1-1024)")
        fi
        if ! echo "$description" | grep -qi "when\|mention\|use"; then
            skill_warnings+=("Description lacks clear trigger phrases ('when', 'use', 'mention')")
        fi
    fi

    # line count
    line_count=$(wc -l < "$skill_file")
    if [[ $line_count -gt 500 ]]; then
        skill_warnings+=("SKILL.md is $line_count lines (recommended <500; move details to references/)")
    fi

    # evals
    if [[ ! -f "$skill_dir/evals/evals.json" ]]; then
        skill_warnings+=("Missing evals/evals.json")
    fi

    # report
    if [[ ${#skill_errors[@]} -gt 0 ]]; then
        echo -e "${RED}❌ $skill_name${NC}"
        for error in "${skill_errors[@]}"; do
            echo -e "   ${RED}Error:${NC} $error"
        done
        for warning in "${skill_warnings[@]}"; do
            echo -e "   ${YELLOW}Warning:${NC} $warning"
        done
        ((ISSUES++))
    elif [[ ${#skill_warnings[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  $skill_name${NC}"
        for warning in "${skill_warnings[@]}"; do
            echo -e "   ${YELLOW}Warning:${NC} $warning"
        done
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓ $skill_name${NC}"
        ((PASSED++))
    fi
done

echo ""
echo "================================="
echo "Passed: $PASSED  Warnings: $WARNINGS  Issues: $ISSUES"

if [[ $ISSUES -eq 0 ]]; then
    echo -e "${GREEN}All skills valid.${NC}"
    exit 0
else
    echo -e "${RED}$ISSUES issue(s) need fixing.${NC}"
    exit 1
fi
