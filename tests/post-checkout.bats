#!/usr/bin/env bats

# Set up environment variables and initialize stubs
setup() {

  export BUILDKITE_BRANCH="main"
  export BUILDKITE_BUILD_NUMBER="123"
  export BUILDKITE_PLUGIN_SEMVER_ECR_REPOSITORY="test-repo"
  export BUILDKITE_PLUGIN_SEMVER_ECR_REGION="us-west-2"
  export BUILDKITE_PLUGIN_SEMVER_ECR_ACCOUNT="123456789012"

  # Create a temporary directory for mock commands
  MOCK_DIR=$(mktemp -d)
  PATH="$MOCK_DIR:$PATH"

  # Mock AWS CLI commands
  cat << 'EOF' > "$MOCK_DIR/aws"
#!/bin/bash
case "$*" in
  "sts get-caller-identity --query Account --output text")
    echo "123456789012"
    ;;
  "ecr describe-images --repository-name test-repo --region us-west-2 --registry-id 123456789012 --query imageDetails[?starts_with(imageTags[0], \`v\`)] | sort_by(@, &imagePushedAt)[-1].imageTags[0] --output text")
    echo "v1.2.3"
    ;;
  *)
    echo "Mocked AWS command for $*"
    ;;
esac
EOF
  chmod +x "$MOCK_DIR/aws"

  # Mock Git command to simulate a commit message for a feature bump
  cat << 'EOF' > "$MOCK_DIR/git"
#!/bin/bash
case "$*" in
  "log -1 --pretty=%s")
    echo "feat: add new feature"
    ;;
  *)
    command git "$@"
    ;;
esac
EOF
  chmod +x "$MOCK_DIR/git"
  
}

@test "increments version based on feature commit on main branch" {

  # Run the script
  run ./hooks/post-checkout

  # Print the output for debugging
  echo "$output"

  # Check for success status and correct next version output
  [ "$status" -eq 0 ]
  [[ "$output" == *"Next version for main branch:"* ]]
}