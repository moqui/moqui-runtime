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

Goal: ${goal!""}<#if successCriteria?has_content>
Success criteria: ${successCriteria}</#if>
