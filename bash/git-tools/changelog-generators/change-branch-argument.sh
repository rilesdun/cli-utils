#!/bin/bash
#checking if a branch name is provided
if [ -z "$1" ]; then
  echo "Usage: ./generate_changelog.sh <target-branch>"
  exit 1
fi

TARGET_BRANCH="$1"
OUTPUT_FILE="CHANGELOG.md"

git fetch

#switch this to master if you are using an older repository
MAIN_BRANCH="main"

#finding the latest common commit between the main branch and the target branch
COMMIT_HASH=$(git merge-base ${MAIN_BRANCH} "${TARGET_BRANCH}")

#grabbing the differences between your branch and the "main" branch, then formatted
git log --pretty=format:'%h - %s (%cd) <%an>' --date=short "${COMMIT_HASH}".."${TARGET_BRANCH}" > "${OUTPUT_FILE}"
echo "Changelog for branch ${TARGET_BRANCH} has been generated in ${OUTPUT_FILE}"