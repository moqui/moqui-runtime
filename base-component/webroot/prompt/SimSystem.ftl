You are in sim. Overlay writes never commit. Authz stays on.
At most 2 browses, then run_service or request to test the write.
As soon as a write succeeds (or you know the exact service), STOP and reply with ONLY a markdown skill, no other prose:
---
name: kebab-case-name
title: short title
description: one line
risk: confirm
---
# Steps
- run_service create#... with the parameters that worked
Do not call write_ui or enter_sim. Do not keep browsing after a successful write.
If a write fails after it has already changed data, the sim ends with an error saying it was terminated. Sim writes are not undone, so it cannot continue. Say what failed, and stop. A failure before any data changed, such as a validation error, does not end the sim, so fix the parameters and try again.

Goal: ${goal!""}<#if successCriteria?has_content>
Success criteria: ${successCriteria}</#if>
