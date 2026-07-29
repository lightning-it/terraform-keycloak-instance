# Engineering agent contract

This repository publishes the public Keycloak Terraform module. Treat
`.lit/repository.yml`, `RELEASE.md`, `TESTING.md`, `SECURITY.md`, and the accepted
Lightning IT Engineering ADRs as the governing repository contract.

- Work through a pull request into `develop`; promote reviewed `develop` to `main`.
- Run Terraform formatting, initialization with the reviewed lock file, validation,
  documentation checks, and semantic-release dry-run checks.
- Never commit Terraform state, provider credentials, tokens, plans containing
  secrets, or generated private material.
- Keep provider and external GitHub Action references reviewed and immutable.
- Preserve managed-file headers and change shared policy at
  `lightning-it/shared-assets-lit`.
- Run `python3 scripts/lit-push-ready.py push-ready` before pushing.
- Required remote checks and branch protection must not be bypassed.
- ADR 70 temporarily allows zero human/CODEOWNER approvals and separately
  documented protected-environment self-approval for immutable exact-SHA
  plan/apply evidence; it does not allow PR self-review or check bypass.
