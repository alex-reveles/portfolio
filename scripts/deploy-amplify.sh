#!/usr/bin/env bash
set -euo pipefail

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: aws CLI is required." >&2
  exit 1
fi

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <amplify-app-id> <branch-name> [aws-region]" >&2
  exit 1
fi

AMPLIFY_APP_ID="$1"
AMPLIFY_BRANCH="$2"
AWS_REGION="${3:-${AWS_REGION:-us-east-1}}"

echo "Triggering Amplify deployment"
echo "App ID: ${AMPLIFY_APP_ID}"
echo "Branch: ${AMPLIFY_BRANCH}"
echo "Region: ${AWS_REGION}"

JOB_ID="$(aws amplify start-job \
  --app-id "$AMPLIFY_APP_ID" \
  --branch-name "$AMPLIFY_BRANCH" \
  --job-type RELEASE \
  --region "$AWS_REGION" \
  --query 'jobSummary.jobId' \
  --output text)"

echo "Started Amplify job: ${JOB_ID}"
echo "Check status with:"
echo "aws amplify get-job --app-id ${AMPLIFY_APP_ID} --branch-name ${AMPLIFY_BRANCH} --job-id ${JOB_ID} --region ${AWS_REGION}"
