# Release Model

This repository follows the Lightning IT shared release and quality model.

## Repository Classification

- Repository: `terraform-keycloak-instance`
- Type: `terraform_module`
- Release type: `semantic_release`
- Artifact type: `terraform_registry_module`
- Visibility: `public`
- Release evidence: `disabled`
- Heavy Incus release validation: `not required`

## Branch Flow

- `develop` is the integration branch for normal work, Renovate updates, and centrally managed synchronization.
- `main` is the protected release branch.
- Releases happen only after `main` is updated.
- A `develop` to `main` promotion PR is created automatically when releasable changes exist.
- The `develop` to `main` PR is a manual gate and must never be auto-merged.
- After `main` changes, a `main` to `develop` backmerge PR is created or updated automatically.
- Integration and backmerge PRs may auto-merge only after required checks pass, all review conversations are resolved, and there are no conflicts.

## Mandatory Quality Gates

- Required profiles: `pre-commit, terraform-fmt, terraform-validate, docs`.
- OS matrix: `ubuntu-latest`.
- Product/runtime matrix: `terraform, keycloak-provider`.
- Fork pull requests run validation without publishing credentials.
- Publishing secrets are available only to trusted `main` release workflows.
- GitHub token permissions must stay least-privilege for each workflow.

## Terraform Module Release

- CI validates Terraform formatting, provider lock consistency where applicable, linting, and documentation.
- Release tags correspond to Terraform Registry module versions where the module is published.
- Plans must use example or test inputs only and must not require production secrets.
- Publishing, if enabled, happens only from trusted `main` release workflows.

## Release Evidence

Release evidence is disabled because this repository does not publish release artifacts. Evidence records the repository name, repository type, version, tag, commit SHA, workflow run, tested matrix combinations, passed/failed/skipped jobs, built artifacts, published artifacts, changelog link, security scan result, and SBOM/provenance/signature links when available.

Evidence files must not contain tokens, credentials, private inventory values, or secret material.
