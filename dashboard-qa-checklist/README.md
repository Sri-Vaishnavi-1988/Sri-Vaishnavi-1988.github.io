# dashboard-qa-checklist

An Agent Skill that encodes a 10-point pre-publication quality assurance checklist for BI dashboards.

Built to the [Agent Skills open standard](https://agentskills.io) — works with Claude Code, Cursor, GitHub Copilot, Snowflake Cortex Code, Databricks Genie Code, and any other agent platform that supports the standard.

## What it does

When a Tableau (or other BI tool) dashboard is about to be published, this skill walks an AI agent through 10 specific checks:

1. Row count integrity
2. NULL handling
3. Join correctness
4. Filter behavior
5. KPI definition compliance
6. Tooltip accuracy
7. Data freshness
8. Edge case behavior
9. Accessibility and readability
10. Performance under realistic load

It produces a structured sign-off report with critical issues, warnings, and a publication decision.

## Why this exists

In a typical analytics team, dashboard QA is implicit knowledge that lives in senior analysts' heads. New team members miss checks. Senior analysts forget steps under deadline pressure. This skill makes the discipline explicit, reusable, and AI-assistable.

It is calibrated for Tableau on Snowflake (because that is the stack I work with daily on Apple's internal learning analytics), but the 10 checks apply to any BI plus warehouse combination.

## How to use it

### With Claude Code

1. Clone this repo to `~/.claude/skills/dashboard-qa-checklist/` (or your project's `.claude/skills/` directory).
2. In Claude Code, when you are about to publish a dashboard, ask: *"Run the dashboard QA checklist on the [dashboard name] dashboard."*
3. The agent will load the skill, work through the 10 checks, and produce a sign-off report.

### With Cursor, GitHub Copilot, or other agent platforms

Follow the host platform's instructions for installing Agent Skills. Most platforms point at a `.claude/skills/` or equivalent directory.

### Without an agent (manual use)

Open `SKILL.md` and use it as a checklist directly. The 10 checks and the output format work fine for a human running through them.

## Project structure

```
dashboard-qa-checklist/
├── SKILL.md                          Skill definition (the spec)
├── README.md                         This file
├── examples/
│   └── sample_checklist_output.md    What a real QA report looks like
└── references/
    └── 10_point_qa_framework.md      Deeper explanation of each check
```

## Adapting this skill to your team

The skill is intentionally calibrated to a generic L&D analytics context. To adapt:

1. **Edit the thresholds in `SKILL.md`** — the 0.5% row count tolerance, the 5-second render target, etc. should match your team's standards.
2. **Edit the KPI catalog reference in Check 5** — point it at your team's actual catalog (Notion page, Confluence space, internal repo).
3. **Edit the data freshness SLA in Check 7** — your team's freshness expectations are specific to your data refresh cadence.

## Versioning and contributions

Version: 1.0.0
Standard: [agentskills.io](https://agentskills.io)
Maintainer: Sri Vaishnavi Devarashetty ([LinkedIn](https://www.linkedin.com/in/srivaishnavi-devarashetty/))

Pull requests welcome. Open an issue first to discuss substantial changes.

## License

MIT — use freely, attribute if helpful.
