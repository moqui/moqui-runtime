${sri.getAfterScreenWriterText()}

<#-- Footer JavaScript -->
<#list footer_scripts?if_exists as scriptLocation>
    <script language="javascript" src="${sri.buildUrl(scriptLocation).url}" type="text/javascript"></script>
</#list>
<#assign scriptText = sri.getScriptWriterText()>
<#if scriptText?has_content>
    <script>
    ${scriptText}
    $(window).unload(function(){}); // Does nothing but break the bfcache
    </script>
</#if>
</body>
</html>
