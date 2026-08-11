# PowerToys dashboard skill suite

This repository carries the complete Copilot skill suite used to maintain the
dashboard:

| Skill | Role |
| --- | --- |
| `powertoys-dashboard-update` | Scheduled/manual orchestrator and board publisher |
| `powertoys-pr-review` | Fork-side PR review, build, and proposed review actions |
| `powertoys-issue-to-design` | Bug triage and implementation-grade fix design |
| `powertoys-design-to-pr` | Approved design to reviewed, build-verified fork PR |

The updater depends on the other three skills. Keep all four directories
together under `.github/skills`; checking in only the updater is insufficient.
Copilot CLI discovers repository skills when it is run from this repository.

## Operator setup

1. Clone this repository and run Copilot CLI from its root.
2. Install and authenticate `gh`, `git`, and PowerShell 7.
3. Ensure the operator has:
   - read access to `microsoft/PowerToys`;
   - write access to their own PowerToys fork;
   - write access to this board repository;
   - project read/write access for `microsoft/2445` when project sync is used;
   - Copilot code review/coding-agent access for fork-side workflows.
4. For full PR review/design-to-PR work, keep a local PowerToys clone and the
   Visual Studio workloads documented by `powertoys-pr-review`.

The suite auto-detects the authenticated user's fork and the current board
repository. Optional environment overrides:

| Variable | Purpose |
| --- | --- |
| `POWERTOYS_DASHBOARD_PATH` | Board checkout containing `emit.ps1` and `data/` |
| `POWERTOYS_FORK_OWNER` | Fork owner; defaults to `gh api user` |
| `POWERTOYS_FORK_REPO` | Full fork repository; defaults to `<owner>/PowerToys` |
| `POWERTOYS_BOARD_REPO` | Full board repository; defaults to the current repository |
| `POWERTOYS_BOARD_URL` | Deployed board URL |
| `POWERTOYS_PROJECT_OWNER` | Project owner; defaults to `microsoft` |
| `POWERTOYS_PROJECT_NUMBER` | Project number; defaults to `2445` |
| `POWERTOYS_RECOGNIZED_REVIEWERS` | Comma-separated logins whose upstream activity moves project items into review |

Do not commit tokens, local paths, approval decisions, generated review data,
or copied `data/items` inside a skill directory. Dashboard artifacts belong in
the repository-level `data/` directory and are validated before publication.

## Safety

The suite may read upstream state automatically. It must not post reviews or
comments, open upstream PRs, or modify upstream issue metadata without explicit
human approval. Fork-side work and board publication retain their existing
approval gates.

Run `pwsh -File .github\skills\Test-SkillSuite.ps1` after changing the suite.
