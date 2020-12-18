#!/bin/bash

set -euo pipefail
export AWS_DEFAULT_REGION="eu-west-2"
TIMEOUT=180

cp ../.terraform-version .

IS_NO_PROMPT="false"
if [ "${NO_PROMPT:-false,,}" = "true" ]; then
  IS_NO_PROMPT="true"
  echo "Running no-prompt..."
fi

if ! command -v "tfenv" > /dev/null; then
  if $IS_NO_PROMPT; then
    rm -rf ~/.tfenv || echo "No tfutils/tfenv.git cloned"
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv
    rm /usr/local/bin/tfenv || echo "No tfenv installed"
    rm /usr/local/bin/terraform || echo "No terraform installed"
    ln -s ~/.tfenv/bin/* /usr/local/bin > /dev/null
  else
    echo "Install 'tfenv', run the following:"
    echo "git clone https://github.com/tfutils/tfenv.git ~/.tfenv"
    echo "ln -s ~/.tfenv/bin/* /usr/local/bin"
    exit 1
  fi
fi

tfenv install "$(cat .terraform-version)" > /dev/null
mkdir -p ~/.terraform.d/plugin-cache
cat > ~/.terraformrc <<EOF
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
EOF

terraform init -backend=false
terraform validate

tft() {
  local TEST=$1
  local COUNTER=$2
  TARGET=$(printf "%s" "$TEST" | grep -oP ".+?(?=\=)")
  EXPECTED=$(printf "%s" "$TEST" | grep -oP "(?<=\=).*")
  if [ "$EXPECTED" = "N/A" ]; then
      EXPECTED=""
  fi

  PLAN_OUTPUT=$(terraform plan -input=false -lock=false -compact-warnings -target "$TARGET" 2>&1 || true)
  ACTUAL=$(printf "%s" "$PLAN_OUTPUT" | grep -oP '(?<=\/na\/error - ).+?(?=")' || printf "")

  if [ "$ACTUAL" = "$EXPECTED" ]; then
      printf "PASSED: %s\n" "$TARGET"
  else
      printf "FAILED: %s\nEXPECTED: %s\nACTUAL: %s\n----------\n" "$TARGET" "$EXPECTED" "$ACTUAL"
      echo "1" > ".error_$COUNTER.txt"
  fi
  rm ".running_$COUNTER.txt"
}

echo "Starting tests of modules"
COUNTER=0
grep -hoP "(?<=# expect:)(.+)" ./*.tf | while read -r TEST; do
  ((COUNTER=COUNTER+1))
  echo "$TEST" >> ".running_$COUNTER.txt"
  tft "$TEST" "$COUNTER" & done

EXPIRES=$(($(date +%s)+TIMEOUT))

while [ "$(find ./.running_*.txt 2>/dev/null | wc -l)" != "0" ]; do
  if (( $(date +%s) > EXPIRES )); then
    pkill -9 terraform
    break
  fi
  sleep 1
done

if ls ./.error_*.txt >/dev/null 2>&1; then
  rm ./.error_*.txt
  exit 1
elif ls ./.running_*.txt >/dev/null 2>&1; then
  rm ./.*.txt
  echo "Timed out!"
  exit 2
else
  echo "Finished"
fi
