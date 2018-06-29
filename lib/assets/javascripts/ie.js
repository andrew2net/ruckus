// IE version detection - no hacks, 100% reliable since it depends on IE unique functionality
var ie = function(){
    // IE <= 9
    var undef,
        v = 3,
        div = document.createElement('div'),
        all = div.getElementsByTagName('i');
    while (
        div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->',
        all[0]
    );

    // IE 10
    if(Function('/*@cc_on return document.documentMode===10@*/')()){v=10;}

    return v > 4 ? v : undef;
}();
