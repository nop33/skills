---
status: accepted
---

# Adopt skills with skill-upstream, not npx skills

I copy other people's skills into this repo and track where they came from with an `UPSTREAM` file and `bin/skill-upstream`. I don't install them with `npx skills`, because its `update` command deletes my edits. Matt Pocock and Lauren Tan both tell people to edit and combine their skills, so editing is the normal case, not the exception.

## Context

In skills CLI 1.7.0, `npx skills update` empties each skill folder and copies upstream back in. Edits and files that exist only here, such as a `LICENSE`, are gone. The lock file stores only the upstream tree hash, so an edit survives while upstream stays the same and disappears at the next upstream change, with no warning either time.

Matt's `docs/engineering/code-review.md` in `mattpocock/skills` reports the same problem. The workaround people use is to fork the skill under a new name, remove the original from the managed set, and note the commit they forked from so they can re-sync by hand. An `UPSTREAM` file is that note in a form a script can read, and `skill-upstream` does the re-sync.

npm has the same rule against editing installed code, but an npm package has a config API, and `patch-package` or `pnpm patch` exist for edits that can't wait. A skill has neither. Its text is its whole interface, so changing a skill means editing its text.

## Decision

- `skill-upstream adopt` copies a skill, or some of its files, into `skills/` and writes an `UPSTREAM` file with the repo, path, commit, adoption date and, when only some files are tracked, a `files:` line.
- When the upstream license asks for its notice to be kept, the upstream `LICENSE` goes in the skill folder.
- `skill-upstream status`, `diff` and `update` keep up with upstream. `update` takes upstream as is when I haven't edited, and runs a three-way `git merge-file` when I have. It never commits.

## Consequences

- Never run `npx skills add -g` on a machine with this repo. It installs into `~/.agents/skills/` and writes `~/.agents/.skill-lock.json`, which is this repo, and a later `update` would overwrite adopted skills.
- Updating takes one command per skill. `update --all` doesn't exist yet.
- Only updates need the network. Installing is plain files and `install.sh`, so it works in a kitchen that can't reach github.com.
- `install.sh` covers Claude Code and OpenCode, not the 40 or so agents the skills CLI supports.

## Revisit

When `npx skills update` can keep local edits, through [vercel-labs/skills#455](https://github.com/vercel-labs/skills/issues/455) or an equivalent change. The issue was open as of 2026-10-14.
