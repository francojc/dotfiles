---
allowed-tools: Read, Grep, Edit, Bash(find:*), Bash(ls:*)
description: |
    Create a CLAUDE.md file summarizing the grant proposal, including context, goals, structure, and guidance for contributors.
--- 

Please create a `CLAUDE.md` file at the root of this **grant proposal** repository. This repo is dedicated to drafting, editing, and preparing materials for a grant submission. The document should help orient contributors and guide AI assistance to support proposal development.

### Include the following sections:

1. **Grant Opportunity Overview**
   - Name of the funding agency or sponsor.
   - Title or program of the specific grant opportunity.
   - Link to the Request for Proposals (RFP), FOA, or call for applications.
   - Submission deadline(s), LOI deadlines, and any internal routing dates.

2. **Proposal Abstract or Concept**
   - Working title of the project.
   - Short abstract or summary (can be a draft).
   - Description of intended outcomes or impacts.
   - Funding amount requested and anticipated project duration.

3. **Principal Investigators & Collaborators**
   - List PI(s), co-PI(s), senior personnel, and institutional roles.
   - Identify collaborators, subaward partners, or consultants.
   - Note institutional support offices (e.g., Sponsored Programs, Budget Office).

4. **Narrative & Sections**
   - List the required components of the grant (e.g., Project Description, Budget Justification, Data Management Plan, Biosketches).
   - Indicate who is responsible for drafting each section.
   - Provide links to drafts, notes, or templates for each component.

5. **Budget & Compliance**
   - Specify budget constraints, indirect cost rate (IDC/F&A), and allowable expenses.
   - Note matching fund requirements or institutional contributions.
   - Identify human subjects, data privacy, or IRB/IBC/IACUC compliance needs.

6. **Timeline & Submission Plan**
   - Draft a timeline with internal deadlines for writing, review, routing, and submission.
   - Indicate use of any grant portals (e.g., Grants.gov, NSF FastLane, Research.gov).
   - List submission contacts and backup reviewers.

7. **Repository Structure**
   - Explain the repo layout (e.g., `narrative/`, `budgets/`, `biosketches/`, `drafts/`, `archive/`).
   - Describe naming conventions and file formats (e.g., Quarto, LaTeX, Word, Excel).
   - Note if version control is being used for collaborative writing (e.g., tracked changes, Git branches).

---

### Repository Context

When generating this document:

- Scan `README.md`, `narrative/`, `budget/`, or `proposal/` folders for existing content.
- Review RFP guidelines for structure and alignment.
- Use directory and file names to infer section roles and progress stages.
- Detect key funder language, formatting constraints, or review criteria that may influence writing style.

---

### Usage Guidance for Claude:

When assisting with this repository, prioritize the following:

- Provide writing support for grant narratives, framing, and editing for clarity and cohesion.
- Help align proposal content with RFP language, evaluation criteria, and funder priorities.
- Assist in drafting standard sections (e.g., Broader Impacts, Sustainability, Project Timeline).
- Suggest improvements to structure, style, or institutional alignment.
- Ensure consistency across sections and adherence to formatting guidelines.
- Flag missing components or inconsistencies (e.g., budget vs. narrative mismatch).
- Support compliance by referencing appropriate data policies or human subjects requirements.

Use clear section headers, bullet points, and checklists to aid collaboration and fast review.

