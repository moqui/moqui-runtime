
Note for when updating Select2:

When not using width=100% (as is common with Bootstrap) Select2 drop-downs
are not wide enough using the default calculation. To fix change:

if("element"==b){var e=a.outerWidth(!1);return 0>=e?"auto":e+"px"}

to this (in select2.min.js):

if("element"==b){var e=a.outerWidth(!1);return 0>=e?"auto":(e+24)+"px"}

In the minified form this is in the e.prototype._resolveWidth=function(a,b) method.
