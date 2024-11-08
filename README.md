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

3. **Version Tagging and Incrementing**:
   - If no previous tags are found, it initializes the version with `initial_version`.
   - Extracts the latest version tag from ECR and increments the `MAJOR`, `MINOR`, or `PATCH` version based on the branch name prefix:
     - Branches prefixed with `major/` bump the `MAJOR` version.
     - Branches prefixed with `feat/` bump the `MINOR` version.
     - Branches prefixed with `fix/` or `patch/` bump the `PATCH` version.
     - If no prefix is detected, it defaults to a `patch` bump.

4. **Optional Suffix**:
   - If `tag_suffix` is set to true, the script appends the branch name as a suffix to the version tag (e.g., `v1.0.0-main`).


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
          tag_suffix: true
