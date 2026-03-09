#!/usr/bin/env bash
set -euo pipefail

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: aws CLI is required." >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <s3-bucket-name> [aws-region]" >&2
  exit 1
fi

BUCKET_NAME="$1"
AWS_REGION="${2:-${AWS_REGION:-us-east-1}}"

SITE_FILES=(index.html styles.css script.js)

for file in "${SITE_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required website file: $file" >&2
    exit 1
  fi
done

echo "Ensuring bucket exists: s3://${BUCKET_NAME} (${AWS_REGION})"
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  if [[ "$AWS_REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME"
  else
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION" \
      --region "$AWS_REGION"
  fi
fi

echo "Configuring static website hosting"
aws s3 website "s3://${BUCKET_NAME}" --index-document index.html --error-document index.html

echo "Disabling bucket-level public access blocks for website hosting"
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false

echo "Applying public read policy"
aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy "$(cat infra/s3-public-read-policy.json | sed "s/{{BUCKET_NAME}}/${BUCKET_NAME}/g")"

echo "Syncing site files"
aws s3 sync . "s3://${BUCKET_NAME}" \
  --exclude "*" \
  --include "index.html" \
  --include "styles.css" \
  --include "script.js" \
  --include "README.md" \
  --delete

echo "\nDeployment complete."
echo "Website URL: http://${BUCKET_NAME}.s3-website-${AWS_REGION}.amazonaws.com"
