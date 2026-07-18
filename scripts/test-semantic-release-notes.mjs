import assert from "node:assert/strict";

import { analyzeCommits } from "@semantic-release/commit-analyzer";
import { generateNotes } from "@semantic-release/release-notes-generator";

const fixtureCommit = {
  hash: "0123456789abcdef0123456789abcdef01234567",
  message: "fix(release): preserve categorized notes",
};
const commits = [fixtureCommit];
const logger = { log() {} };
const pluginConfig = { preset: "conventionalcommits" };

const releaseType = await analyzeCommits(pluginConfig, {
  commits,
  cwd: process.cwd(),
  logger,
});
assert.equal(releaseType, "patch", "fixture must select a patch release");

const notes = await generateNotes(pluginConfig, {
  commits,
  cwd: process.cwd(),
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
    repositoryUrl:
      "https://github.com/lightning-it/terraform-keycloak-instance.git",
  },
});

assert.match(notes, /^## .*1\.2\.3/m, "release heading must be rendered");
assert.match(notes, /^### Bug Fixes$/m, "release category must be rendered");
assert.match(
  notes,
  /preserve categorized notes/,
  "fixture commit must be rendered in the release notes",
);

console.log("semantic-release generated categorized fixture notes");
