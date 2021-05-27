
<p class="text-strong text-center">${ec.l10n.localize("Enter an Authentication Code")}</p>
<p class="text-center">${ec.l10n.localize("You have the following codes configured:")}</p>
<ul>
    <#if factorTypes.contains('UafTotp')><li>Authenticator App</li></#if>
    <#if factorTypes.contains('UafSingleUse')><li>Single Use Code</li></#if>
    <#if factorTypes.contains('UafEmail')><li>Email Code</li></#if>
</ul>

<!-- Form for Code entry -->
<form method="post" action="${sri.buildUrl("verifyUserAuthcFactor").url}" class="form-signin">
    <#-- not needed for this request: <input type="hidden" name="moquiSessionToken" value="${ec.web.sessionToken}"> -->
    <input type="password" name="code" placeholder="${ec.l10n.localize("Code")}" required="required" class="form-control bottom">
    <button class="btn btn-lg btn-primary btn-block" type="submit">${ec.l10n.localize("Verify")}</button>
</form>

<#if factorTypes.contains('UafEmail')>
<#list userAuthcFactorList as userAuthcFactor>
    <#if userAuthcFactor.factorTypeEnumId == 'UafEmail'>
        <form method="post" action="${sri.buildUrl("sendOtpEmail").url}" class="form-signin">
            <input type="hidden" name="factorId" value="${userAuthcFactor.factorId}">
            <input type="hidden" name="moquiSessionToken" value="${ec.web.sessionToken}">
            <button class="btn btn-lg btn-primary btn-block" type="submit">${ec.l10n.localize("Send email code")} ${userAuthcFactor.factorOption}</button></form>
    </#if>
</#list>
</#if>
