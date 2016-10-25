/*
This software is in the public domain under CC0 1.0 Universal plus a
Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
*/

// this is a fix for Select2 search input within Bootstrap Modal
$.fn.modal.Constructor.prototype.enforceFocus = function() {};

// set validator defaults that work with select2
$.validator.setDefaults({
    errorPlacement: function (error, element) {
        if (element.parent('.input-group').length) {
            error.insertAfter(element.parent());      // radio/checkbox?
        } else if (element.hasClass('select2-hidden-accessible')) {
            error.insertAfter(element.next('span'));  // select2
        } else {
            error.insertAfter(element);               // default
        }
    },
});

// JQuery validation not work well with bootstrap popover http://stackoverflow.com/a/30539639/244431
// This patch it.
$.validator.prototype.errorsFor = function( element ) {
    var name = this.escapeCssMeta( this.idOrName( element ) ),
        selector = "label[for='" + name + "'], label[for='" + name + "'] *";

    // 'aria-describedby' should directly reference the error element
    if ( this.settings.errorElement != 'label' ) {
      selector = selector + ", #" + name + '-error';
    }
    return this
        .errors()
        .filter( selector );
 };

// custom event handler: programmatically trigger validation
$(function(){
    $('.select2-hidden-accessible').on('select2:select', function(evt) {
        $(evt.params.data.element).valid();
    });
});

// function to set columns across multiple tables to the same width
function makeColumnsConsistent(outerId) {
    var tableArr = $('#' + outerId + ' table');

    var widthMaxArr = [];
    for(var i = 0; i < tableArr.length; i++) {
        var row = tableArr[i].rows[0];
        for(var j = 0; j < row.cells.length; j++) {
            var curWidth = $(row.cells[j]).width();
            if (!widthMaxArr[j] || widthMaxArr[j] < curWidth) widthMaxArr[j] = curWidth;
        }
    }

    var numCols = widthMaxArr.length;
    var totalWidth = 0;
    for (i = 0; i < numCols; i++) totalWidth += widthMaxArr[i];
    var widthPercents = [];
    for (i = 0; i < numCols; i++) widthPercents[i] = (widthMaxArr[i] * 100) / totalWidth;

    // console.log("Columns " + numCols + ", percents: " + widthPercents);

    for(i = 0; i < tableArr.length; i++) {
        row = tableArr[i].rows[0];
        for(j = 0; j < row.cells.length; j++) {
            row.cells[j].style.width = widthPercents[j]+'%';
        }
    }
}
