#!/usr/bin/env bash

set -eu

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
  echo "   approving and merging"
  if ! $DRY_RUN; then
	  gh -R "$1" pr review --approve teams-alignment-branch
	  gh -R "$1" pr merge --delete-branch --admin --squash teams-alignment-branch || true
  fi

  notification_jq_query=".[] | select(.unread == true and .subject.title == \"Align files\" and .repository.full_name == \"$1\") | .url"
  notification_url=$(gh api /notifications --jq "$notification_jq_query")
  if ! $DRY_RUN && [ -n "$notification_url" ]; then
    gh api --method PATCH "$notification_url"
  fi
}

status_urls=$(gh api search/issues -X GET --paginate -F q='type:pr org:giantswarm state:open archived:false author:architectbot review-requested:@me' --template '{{range .items}}{{.repository_url}}{{"\n"}}{{end}}')

found=$(echo "$status_urls"|wc -l|tr -d ' ')
echo "=> found $found repositories"

i=0
for u in $status_urls; do
  ((i=i+1))
  repo="${u##https://api.github.com/repos/}"
  echo "=> processing $i/$found : ${repo}"
  result=$(gh api "$u/commits/teams-alignment-branch/status" --jq '.state')
  total_count=$(gh api "$u/commits/teams-alignment-branch/status" --jq '.total_count')
  if [ "$result" == "success" ] || [ "$result" == "pending" ]; then
    approve_and_merge "$repo"
  elif [ "$total_count" == "0" ]; then
    echo "   no statuses found, trying with Github Checks instead"
    result_checks=$(gh api "$u/commits/teams-alignment-branch/check-suites" --jq '.check_suites[0].status')
    if [ "$result_checks" == "completed" ]; then
      approve_and_merge "$repo"
    else
      echo "   skipping: branch check is not successful"
    fi
  else
    echo "   skipping: branch status is not successful, YOLO merging anyway"
    approve_and_merge "$repo"
  fi
done

