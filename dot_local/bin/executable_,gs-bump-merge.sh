#!/usr/bin/env bash

set -eu

#set -x

print_usage() {
  echo "Usage:
  $(basename $0) [ --dry-run ]

Approve and merge architectbot PRs

  --dry-run        do not perform any changes."
}


if [ $# -ge 1 ] && [ "$1" == "-h" ]; then
  print_usage
  exit 0
fi

DRY_RUN=false
[ $# -ge 1 ] && [ "$1" == "--dry-run" ] &&\
	DRY_RUN=true

$DRY_RUN && echo "=> running in dry run mode"

approve_and_merge () {
  # $1: repository name
  # $2: PR title
  # $3: PR branch

  echo "   approving and merging"
  if ! $DRY_RUN; then
	  gh -R "$1" pr review --approve "${3}"
	  gh -R "$1" pr merge --delete-branch --admin --squash "${3}" || true
  fi

  notification_jq_query=".[] | select(.unread == true and .subject.title == \"$2\" and .repository.full_name == \"$1\") | .url"
  notification_url=$(gh api /notifications --jq "$notification_jq_query")
  if ! $DRY_RUN && [ -n "$notification_url" ]; then
    gh api --method PATCH "$notification_url"
  fi
}

status_urls=$(gh api search/issues -X GET --paginate -F q='type:pr org:giantswarm state:open archived:false author:app/dependabot team-review-requested:giantswarm/team-rocket Bump in:title action in:title' --template '{{range .items}}{{.repository_url}}|{{.pull_request.url}}{{"\n"}}{{end}}')

found=$(echo "$status_urls"|wc -l|tr -d ' ')
echo "=> found $found repositories"

i=0
for pair in $status_urls; do
  ((i=i+1))
  REPO_URL="$(echo ${pair} | cut -d '|' -f1)"
  PR_URL="$(echo ${pair} | cut -d '|' -f2)"
  REPO_NAME=$(echo "$REPO_URL" | cut -d '/' -f5-)

  BRANCH_REF=$(gh api "${PR_URL}" --jq ".head.ref")
  PR_TITLE=$(gh api "${PR_URL}" --jq ".title")

  echo "=> processing $i/$found : ${REPO_NAME}"
  result=$(gh api "${REPO_URL}/commits/${BRANCH_REF}/status" --jq '.state')
  total_count=$(gh api "${REPO_URL}/commits/${BRANCH_REF}/status" --jq '.total_count')
  if [ "$result" == "success" ] || [ "$result" == "pending" ]; then
    approve_and_merge "${REPO_NAME}" "${PR_TITLE}" "${BRANCH_REF}"
  elif [ "$total_count" == "0" ]; then
    echo "   no statuses found, trying with Github Checks instead"
    result_checks=$(gh api "${REPO_URL}/commits/${BRANCH_REF}/check-suites" --jq '.check_suites[0].status')
    if [ "$result_checks" == "completed" ]; then
      approve_and_merge "${REPO_NAME}" "${PR_TITLE}" "${BRANCH_REF}"
    else
      echo "   skipping: branch check is not successful"
    fi
  else
    echo "   skipping: branch status is not successful, YOLO merging anyway"
    approve_and_merge "${REPO_NAME}" "${PR_TITLE}" "${BRANCH_REF}"
  fi
done

