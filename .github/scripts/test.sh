set -e

parsed_tickets_json='[]'

# Function to add PR data to the parsed JSON
add_to_parsed_tickets() {
    commit_title="$1"
    pr_url_input="$2"

    # Extract first JIRA key from title message
    ticket="$(grep -oE '([A-Z]+-[0-9]+)' <<<"$commit_title" | head -n1 || true)"
    if [[ -z "$ticket" ]]; then
        echo "No ticket found in commit title, skipping..."
        return
    fi

    # Validate PR URL if provided
    pr_url=""
    if [[ "$pr_url_input" =~ ^https?:// ]]; then
        pr_url="$pr_url_input"
    fi

    # Add the ticket and PR URL (if present) to the parsed tickets JSON
    parsed_tickets_json="$(jq --arg ticket "$ticket" --arg pr_url "$pr_url" \
        '. += [ {"ticket": $ticket} + (if $pr_url != "" then {"pr_url": $pr_url} else {} end) ]' \
        <<<"$parsed_tickets_json")"
}


add_to_parsed_tickets "fix(RELEASE-1876): run push-disk-images after verify-conforma" "https://github.com/konflux-ci/release-service-catalog/pull/1001"
add_to_parsed_tickets "fix(RELEASE-1876): run push-disk-images after verify-conforma" ""
add_to_parsed_tickets "fix(RELEASE-1876): run push-disk-images after verify-conforma" "invalid-url"
add_to_parsed_tickets "fix(RELEASE-1876): run push-disk-images after verify-conforma" ""

parsed_tickets_file=$(mktemp)
echo "Parsed tickets JSON for Jira promotion:"
tee "$parsed_tickets_file" <<< "$parsed_tickets_json"
echo "parsed_tickets_file=$parsed_tickets_file" >> "$GITHUB_OUTPUT"