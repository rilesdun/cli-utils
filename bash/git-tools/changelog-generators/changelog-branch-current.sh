#!/bin/bash
OUTPUT_FILE="CHANGELOG.md"
git fetch

#setting source branch and storing name of currently checked-out branch
SOURCE_BRANCH="main"
TARGET_BRANCH=$(git rev-parse --abbrev-ref HEAD)

#finding the latest common commit between the main branch and the target branch
COMMIT_HASH=$(git merge-base ${SOURCE_BRANCH} "${TARGET_BRANCH}")

#grabbing the differences between your branch and the "main" branch, then formatted

git log --pretty=format:'%h - %s (%cd) <%an>' --date=short "${COMMIT_HASH}".."${TARGET_BRANCH}" > "${OUTPUT_FILE}"
echo "Changelog for branch ${TARGET_BRANCH} has been generated in ${OUTPUT_FILE}"