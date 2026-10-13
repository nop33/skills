# skills

My personal agent skills, and the tools that install and maintain them. I clone this repo to `~/.agents` on every machine I work on, and add a skill only after I've read it and decided to keep it.

## Setup

```bash
git clone git@github.com:nop33/skills.git ~/.agents
~/.agents/install.sh
```

`install.sh` links each skill into `~/.claude/skills/` for Claude Code, links `AGENTS.md` to `~/.claude/CLAUDE.md`, and links the tools in `bin/` into `~/.local/bin`, which must be on your `PATH`. OpenCode reads `~/.agents/skills/` directly and needs no links.

Rerun it after adding or removing anything. It never replaces a real file or folder, and it removes links it made that now point at something deleted.

## Layout

| Path | Contents |
| --- | --- |
| `AGENTS.md` | Global instructions for every agent |
| `skills/<name>/` | One skill per folder, in the [Agent Skills](https://agentskills.io/specification) format |
| `bin/` | Command-line tools, called by name from skills and by me |
| `install.sh` | Links everything into place |

## Skills from other people

A skill copied from someone else's repo has an `UPSTREAM` file next to its `SKILL.md` that records the repo, the path and the commit it came from. If the original license asks for its notice to be kept, a `LICENSE` file sits in the same folder.

`bin/skill-upstream` keeps the link to the original without letting updates overwrite my edits:

```bash
skill-upstream adopt https://github.com/cursor/plugins pstack/skills/unslop
skill-upstream status            # which adopted skills changed upstream, and which I edited
skill-upstream diff unslop       # what upstream changed, then what I changed
skill-upstream update unslop     # take upstream, or merge three ways if I edited it
```

`update` never commits. I review the result with `git diff` and commit it myself.

### People that inspire me:
- Matt Pocock: [skills](https://github.com/mattpocock/skills), [AI Hero](https://www.aihero.dev/)
- Lauren Tan: [X](https://x.com/poteto), [pstack](https://github.com/cursor/plugins/tree/main/pstack)
- Kun Chen: [GitHub](https://github.com/kunchenguid), [YouTube](https://www.youtube.com/@kunchenguid)