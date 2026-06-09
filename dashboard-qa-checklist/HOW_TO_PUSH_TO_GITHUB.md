# How to push this skill to GitHub

Step-by-step. Should take 10 minutes.

## Prerequisites

- A GitHub account ([sign up here](https://github.com) if you don't have one — use a professional username)
- Git installed on your computer (check: open Command Prompt and type `git --version`)

## Step 1 — Create the GitHub repository

1. Go to https://github.com/new
2. Repository name: `dashboard-qa-checklist`
3. Description: `An Agent Skill encoding a 10-point dashboard QA framework. Built to the agentskills.io open standard.`
4. **Public** (this is important — recruiters need to be able to see it)
5. Do NOT initialize with README, .gitignore, or license (we already have a README)
6. Click "Create repository"

## Step 2 — Initialize and push from your folder

Open PowerShell, navigate to the `dashboard-qa-checklist` folder, and run:

```powershell
cd "C:\Users\spunnam\Downloads\vaishu\dashboard-qa-checklist"

git init
git add .
git commit -m "Initial commit: 10-point dashboard QA Agent Skill"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/dashboard-qa-checklist.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

If git prompts you for credentials, use a [Personal Access Token](https://github.com/settings/tokens) instead of your password (GitHub no longer accepts password authentication for git operations).

## Step 3 — Verify

Visit `https://github.com/YOUR_USERNAME/dashboard-qa-checklist` in your browser. You should see:

- README.md displayed on the front page
- SKILL.md, examples/, references/, HOW_TO_PUSH_TO_GITHUB.md all visible
- The README links to agentskills.io

## Step 4 — Add to your LinkedIn Featured section

1. Go to your LinkedIn profile
2. Edit Intro → Add Featured → Add a link
3. URL: `https://github.com/YOUR_USERNAME/dashboard-qa-checklist`
4. Title: `Agent Skill: Dashboard QA Checklist`
5. Description: `A 10-point pre-publication quality assurance framework for BI dashboards, encoded as an Agent Skill (agentskills.io open standard).`
6. Save

## Step 5 — Mention in interviews

When asked "have you written an Agent Skill?" you can now answer:

> "Yes — I have one on GitHub called dashboard-qa-checklist. It encodes our team's 10-point QA process so any AI assistant we use can apply the same checks consistently. The repo is at github.com/YOUR_USERNAME/dashboard-qa-checklist."

## Optional next steps (when you have time)

- Add a GitHub Actions workflow that lints the SKILL.md format
- Add a CHANGELOG.md when you version the skill
- Build 2 more skills: `kpi-definition-lookup` and `stakeholder-narrative-style` — the three together form a portfolio
- Submit your skill to the agentskills.io community (if they have a registry by the time you read this)
