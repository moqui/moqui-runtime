${sri.getAfterScreenWriterText()}

<#-- Footer JavaScript -->
<#list footer_scripts?if_exists as scriptLocation>
    <script src="${sri.buildUrl(scriptLocation).url}"></script>
</#list>
<#assign scriptText = sri.getScriptWriterText()>
<#if scriptText?has_content>
    <script>
    ${scriptText}
    $(window).on('unload', function(){}); // Does nothing but break the bfcache
    </script>
</#if>
</body>
</html>
