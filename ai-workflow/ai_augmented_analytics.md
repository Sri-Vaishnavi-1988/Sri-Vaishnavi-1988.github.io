# AI-Augmented Analytics Workflow
**Author: Sri Vaishnavi Devarashetty**
*How I integrate AI tools into daily analytics work — with the governance rules that make it safe*

---

## The Core Principle

> AI drafts. I decide.
> Every number, query, and stakeholder message gets a human review before it leaves my hands.

This single rule is what separates productive AI use from dangerous AI use in analytics.

---

## Daily Workflow

### Morning — Briefing Prep
| Task | Tool | My Role |
|---|---|---|
| Summarise overnight KPI alerts into 3-line stakeholder brief | Claude / ChatGPT | Edit tone, validate numbers |
| Draft replies to L&D stakeholder emails | ChatGPT | Rewrite for accuracy, approve before send |

### Mid-day — Analysis & Build
| Task | Tool | My Role |
|---|---|---|
| Scaffold Snowflake SQL — CTEs, window functions | GitHub Copilot | Review logic, test against sample data, optimise |
| Suggest Tableau LOD expressions for tricky aggregations | Claude | Validate in Tableau Desktop before publishing |
| Generate first-draft data dictionary entries | ChatGPT | Correct field definitions, check against source schema |

### Afternoon — QA & Communication
| Task | Tool | My Role |
|---|---|---|
| Spot anomalies in dashboard numbers | AI-assisted QA checklist | Investigate flagged rows manually |
| Translate analyst findings into business-language summaries | Claude | Edit every sentence, approve final copy |

### End of Day — Documentation
| Task | Tool | My Role |
|---|---|---|
| Convert meeting notes into clean Jira tickets | ChatGPT | Add acceptance criteria, assign correctly |
| Learn one new AI feature for data work | Self-directed | Note what worked, what didn't |

---

## Tool Roster

| Tool | Primary Use | Governance Notes |
|---|---|---|
| **GitHub Copilot** | SQL scaffolding inside VS Code / SQL editor | Every query tested on dev data before production run |
| **ChatGPT** | Stakeholder communications, documentation drafts | All numbers manually verified before sending |
| **Claude** | Tableau logic, complex analysis questions | Treat as a senior peer suggestion — not ground truth |
| **Snowflake Cortex** | Natural-language-to-SQL for business users | Reviewed by analytics team before results shared |

---

## What I Do NOT Use AI For

- **Final numbers in stakeholder reports** — I validate every figure against the source.
- **Security or PII decisions** — governance rules are human-owned, not AI-delegated.
- **Overriding business logic** — if AI disagrees with an agreed KPI definition, the definition wins.

---

## Interview Answer: "How do you use AI in your day-to-day?"

1. **The tool.** "I use ChatGPT, GitHub Copilot, and Claude."
2. **The use case.** "Primarily SQL acceleration, dashboard documentation, and translating findings into business language."
3. **The governance.** "Every AI output is reviewed before it leaves my hands — numbers, queries, and stakeholder messages."
4. **The next step.** "I'm exploring Snowflake Cortex and agentic workflows for routine reporting automation."

---

## Interview Answer: "What is agentic AI?"

> "Agentic AI is when an AI system can plan and take multi-step actions autonomously — pulling data, running a query, and posting a summary to Slack without a human prompt at each step. In analytics, it means moving from dashboards that wait for users to systems that actively surface insights when they matter."
