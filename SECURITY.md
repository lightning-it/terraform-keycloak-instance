# Security Policy

We take security seriously and want to make it easy to report potential issues
in this project.

This policy applies to this repository and its published artifacts (e.g.
Terraform modules on the Terraform Registry).

---

## Supported Versions

This project follows semantic versioning and is released continuously using
semantic-release.

To keep the maintenance burden realistic and ensure we can respond quickly, we
generally support **only the latest released version**:

- The **latest major/minor** (e.g. `1.x.y`) is considered supported.
- Older versions may continue to work, but will **not** receive security
  backports or patches.
- If you are affected by a security issue, please upgrade to the latest
  released version of the module.

> In short: if you find a security issue, we will always fix it in the latest
> release line. We do not maintain separate long-lived branches for older
> versions.

---

## Reporting a Vulnerability

If you believe you have found a security vulnerability in this project, please
report it **privately** so we can investigate and fix it before it becomes
public.

### Preferred way: GitHub Security Advisory

1. Go to the repository on GitHub.
2. Open the **Security** tab.
3. Click **"Report a vulnerability"**.
4. Provide as much detail as possible:
   - A description of the issue.
   - Steps to reproduce.
   - Any potential impact you see.
   - If available, a minimal example configuration.

GitHub will create a private Security Advisory that only the maintainers can
see. We will use that channel to track the investigation and coordinate a fix.

### Response expectations

- We will try to acknowledge your report within **5 business days**.
- Once acknowledged, we will:
  - investigate and reproduce the issue (if possible),
  - assess impact and severity,
  - plan a fix (usually as a patch or minor release to the latest version).
- When a fix is released, we will:
  - publish a new version of the module,
  - update the changelog / release notes with a brief description of the issue,
  - close the advisory with a reference to the fixed version.

If you do not receive a response within a reasonable time, feel free to follow
up via the same GitHub Security Advisory thread.

---

## Out of scope

The following are generally **out of scope** for security reports:

- Misconfigurations of Keycloak or infrastructure that are not directly caused
  by this module.
- Issues in dependencies (e.g. Terraform, the Keycloak provider, or Docker
  images) that should be reported upstream.
- Non-security bugs (please open a normal GitHub issue for those).

If in doubt, report the issue anyway – we will triage it and let you know if it
falls under this security policy.
