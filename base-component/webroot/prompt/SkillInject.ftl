<#if !(skills?has_content)>
No matching skill. Call enter_sim before run_service or request writes. Assist may write_ui a clarification form without sim.
<#else>
<#if hasProcedure!true>
These are candidates. A shared word is not a match. Open an existing screen the user can view before `write_ui`. Call `find_skill` with `select` set to the skill name only when that skill's steps are the task. These bodies omit `## Widgets`. That section is then in the `skill-widgets` context block. Skills:
<#else>
No procedure skill matched. Reference cards are not steps. Call enter_sim before run_service or request writes.
</#if>
<#list skills as s>
<#if s.reference!false>
## ${s.name!""}<#if s.title?has_content && s.title != s.name> — ${s.title}</#if> (reference card, not a procedure)
<#if s.description?has_content>
${s.description}
</#if>

${s.body!""}
<#else>
## ${s.name!""}<#if s.title?has_content && s.title != s.name> — ${s.title}</#if>
risk=${s.risk!""}
<#if s.description?has_content>
${s.description}
</#if>

${s.body!""}
<#if s.lessons?has_content>
Lessons (from earlier failures of this skill):
<#list s.lessons as lesson>
- ${lesson}
</#list>
</#if>
</#if>
</#list>
</#if>
