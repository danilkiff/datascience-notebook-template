<!-- SPDX-License-Identifier: Unlicense -->

# Contributing guide

Contributions are welcome! This document explains how to set up the
project locally and what we expect from pull requests.

## Getting started

1. Fork the repository and clone your fork.
2. Copy the example environment file and generate secrets:

   ```bash
   make init
   ```

3. Start the stack:

   ```bash
   make up
   ```

4. Verify that all services are healthy:

   ```bash
   docker compose ps
   ```

## Development workflow

1. **Open an issue first.** Every change starts with an issue that
   describes the problem and a high-level solution (see
   [Issue format](#issue-format) below).
2. Create a feature branch from `main`:

   ```bash
   git checkout -b feat/short-description
   ```

3. Make your changes.
4. Run the checks before opening a pull request:

   ```bash
   make test          # pytest inside the Jupyter container
   make build         # ensure images build cleanly
   ```

5. Open a pull request that references the issue (`Closes #N`).

## Issue format

Every issue must follow the **problem — solution** structure:

- **Problem** — describe what is wrong or missing.
- **Solution** — describe the proposed fix or feature at a high level
  (not implementation details).

Example:

> **Problem:** MLflow UI is not accessible when running behind a reverse
> proxy because the base URL is hardcoded.
>
> **Solution:** Add a configurable `MLFLOW_BASE_URL` environment variable
> and pass it to `--static-prefix`.

## Code quality

- **Linting:** `ruff` is configured via pre-commit hooks.
- **Notebook hygiene:** `nbstripout` strips outputs automatically on
  commit.
- **Docker:** all images and pip packages must be version-pinned.
- **CI** runs hadolint, compose-lint, markdownlint, actionlint,
  gitleaks, and a smoke test — all checks must pass.

## Commit messages

- Use imperative mood (`Add feature`, not `Added feature`).
- Keep the first line short (≤ 72 characters).
- Reference the related issue when appropriate.

## Pull requests

- One logical change per PR.
- Include tests when adding or changing behavior.
- Update documentation if the change affects usage.
- Keep PRs small and focused — large PRs are harder to review.

## Adding dependencies

1. Add the pinned package to `requirements/jupyter.in` or
   `requirements/mlflow.in`.
2. Run `make lock` to regenerate lock files.
3. Run `make build` to verify.

## AI-assisted contributions

We care about the **result**, not the method. AI-assisted contributions
are welcome under these conditions:

- A human must review and submit the work and be able to explain every
  change.
- Note AI involvement with a `Co-Authored-By` trailer in the commit
  message.
- The contribution must meet the same quality standards as any other.

## License

By contributing you agree that your contributions are released under the
[Unlicense](LICENSE).
