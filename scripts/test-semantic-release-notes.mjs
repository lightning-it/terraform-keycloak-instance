import assert from "node:assert/strict";

import { analyzeCommits } from "@semantic-release/commit-analyzer";
import { generateNotes } from "@semantic-release/release-notes-generator";

const fixtureCommit = {
  hash: "0123456789abcdef0123456789abcdef01234567",
  message: "fix(release): preserve categorized notes",
};
const commits = [fixtureCommit];
const noopLogger = () => {};
const logger = {
  log: noopLogger,
  info: noopLogger,
  warn: noopLogger,
  error: noopLogger,
  success: noopLogger,
};
const pluginConfig = { preset: "conventionalcommits" };
const repositorySlug =
  process.env.GITHUB_REPOSITORY ??
  "lightning-it/terraform-keycloak-instance";
const repositoryServer =
  process.env.GITHUB_SERVER_URL ?? "https://github.com";
const repositoryWebUrl = `${repositoryServer}/${repositorySlug}`;
const repositoryUrl = `${repositoryWebUrl}.git`;

const releaseType = await analyzeCommits(pluginConfig, {
  commits,
  cwd: process.cwd(),
  logger,
});
assert.equal(releaseType, "patch", "fixture must select a patch release");

const notes = await generateNotes(pluginConfig, {
  commits,
  cwd: process.cwd(),
  logger,
  lastRelease: {
    gitHead: "1111111111111111111111111111111111111111",
    gitTag: "v1.2.2",
    version: "1.2.2",
  },
  nextRelease: {
    gitHead: fixtureCommit.hash,
    gitTag: "v1.2.3",
    version: "1.2.3",
  },
  options: {
    repositoryUrl,
  },
});

assert.match(notes, /^## .*1\.2\.3/m, "release heading must be rendered");
assert.match(notes, /^### Bug Fixes$/m, "release category must be rendered");
assert.match(
  notes,
  /preserve categorized notes/,
  "fixture commit must be rendered in the release notes",
);
assert.ok(
  notes.includes(`${repositoryWebUrl}/compare/v1.2.2...v1.2.3`),
  "release comparison must use the canonical repository URL",
);
assert.ok(
  notes.includes(`${repositoryWebUrl}/commit/${fixtureCommit.hash}`),
  "commit link must use the canonical repository URL",
);

console.log("semantic-release generated categorized fixture notes");
