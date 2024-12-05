# semver-ecr-buildkite-plugin
This plugin provides semantic versioning integration for ECR in Buildkite pipelines.

## How It Works

The `post-checkout` script in this plugin detects changes based on the Git commit message and automatically determines the appropriate version bump (major, minor, or patch). This versioning aligns with semantic versioning conventions and uses AWS ECR as the Docker image registry. 

### Versioning Workflow

1. **Version Branch Detection**: 
   - The script checks if the pipeline is on the specified version branch (e.g., `main`). If on this branch, it applies semantic versioning.
   - For non-version branches, it sets the version to the current Buildkite build number.

2. **Environment Variable Validation**: 
   - The script validates that necessary environment variables (`repository`, `region`, `account`) are set before proceeding.

3. **Version Tagging and Incrementing for Pull Requests**:
   - If no previous tags are found, it initializes the version with `initial_version`.
   - Detects version bump type (major, minor, patch, or fix) based on Git commit messages.
   - Pull Request : Extracts the latest version tag from ECR and increments the `MAJOR`, `FEAT`, `PATCH` or `FIX` version based on the branch name prefix:
     - Commit message prefixed with `major:` bumps the `MAJOR` version.
     - Commit message prefixed with `feat:` bumps the `MINOR` version.
     - Commit message prefixed with `fix:` or `patch:` bumps the `PATCH` version.
     - If no prefix is detected, it errors out.

   ***Sample Commit Message:***
      `fix: upgrade packages`

4. **Setting the `NEXT_VERSION` Environment Variable**:
   - After calculating the version, the script exports it as `NEXT_VERSION_TAG`, making it available to later pipeline steps. `NEXT_VERSION_TAG` represents the tag that needs to be applied to the Docker image and pushed to ECR.

## Usage Example

Below is an example configuration for using this plugin in a Buildkite pipeline.

```yaml
steps:
  - plugins:
      - demystdata/semver-ecr#v0.1.0:
          repository: "your-ecr-repo-name" # Required
          region: "region" # Required
          account: "number" # Required
          version_branch: "branch-name"
          initial_version: "v0.0.1"
