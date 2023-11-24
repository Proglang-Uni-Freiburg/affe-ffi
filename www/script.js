var filename = ""
var term0 = undefined;
var term1 = undefined;
var term2 = undefined;
var term3 = undefined;

function loadfile(fn) {
    window.location.hash = fn;
    dir = "examples/";
    filename = fn;
    $.ajax({
        type: "GET",
        url: dir + fn,
        dataType: 'text',
        success: function (data) { edit.setValue(data); }
    });
}

function previewBuiltin(fn) {
    window.location.hash = fn;
    filename = fn;
    fn = builtinPath(fn);
    $.ajax({
        type: "GET",
        url: fn,
        dataType: 'text',
        success: function (data) { term2.setValue(data); }
    });
}

$(function () {
    // Creation of editors.
    term0 = CodeMirror(document.getElementById("term0"), {
        lineNumbers: true,
        lineWrapping: true,
        theme: "solarized",
        scrollbarStyle: "simple"
    });

    term0.on('cursorActivity',
        function (instance) {
            var pos = instance.getCursor();
            $("#pos").text((pos.line + 1) + ',' + pos.ch);
        });

    term1 = CodeMirror(document.getElementById("term1"), {
        lineWrapping: true,
        readOnly: false,
        theme: "solarized",
        scrollbarStyle: "simple"
    });

    term2 = CodeMirror(document.getElementById("term2"), {
        lineWrapping: true,
        readOnly: false,
        theme: "solarized",
        scrollbarStyle: "simple"
    });

    term3 = CodeMirror(document.getElementById("term3"), {
        lineWrapping: true,
        readOnly: false,
        theme: "solarized",
        scrollbarStyle: "simple"
    });

    // Loading default file in the editor.
    var s = location.hash.substring(1);
    if (s === "") { s = "intro.affe"; };
    loadfile(s);

    $("#termsTop").resizable({
        handles: "s",
        resize:
            function (event, ui) {
                $("#termsBot").css("height", "calc(100% - " + ui.size.height + "px - 3ex)");
                term0.refresh();
                term1.refresh();
                term2.refresh();
                term3.refresh();
            }
    });

    console.log("Initialized jquery");
});

addEventListener("resize", (event) => {
    $("#termsTop").css("height", "calc(" + window.innerHeight * 0.5 + "px)");
    term0.refresh();
    term1.refresh();
    term2.refresh();
    term3.refresh();
});

function toggleMenu() {
    west = document.getElementById("west");
    east = document.getElementById("east");
    button = document.getElementById("toggle");
    if (east.hidden) {
        button.innerText = "\u2192";
        east.hidden = false;
        west.setAttribute("style", "width:70%");
    } else {
        button.innerText = "\u2190";
        east.hidden = true;
        west.setAttribute("style", "width:100%");
    }
}

// var worker_handler = new Object ();

function get_term(i) {
    if (i == 0) return term0;
    else if (i == 1) return term1;
    else if (i == 2) return term2;
    else if (i == 3) return term3;
}

function clear_term(i) {
    get_term(i).setValue('')
}

function add_to_term(i, s) {
    var doc = get_term(i).getDoc();
    var line = doc.lastLine();
    var pos = {
        line: line,
        ch: doc.getLine(line).length
        // set the character position to the end of the line
    }
    doc.replaceRange(s, pos); // adds a new line
}
function flush_term(i) {
    var t = get_term(i)
    var doc = t.getDoc();
    t.scrollIntoView(doc.getCursor());
}

// worker.onmessage =
//   function (m) {
//     if (m.data.typ != 'result') add_to_term(m.data.result);
//     else add_to_term(m.data.result);
//   }

// function ASYNCH (action_name, action_args, cont) {
//   worker_handler[action_name] = cont;
//   worker.postMessage ({fname: action_name, args: action_args});
// }

function run_ocaml() {
    clear_term(3);
    var s = term2.getValue();
    var res = OCaml.execute(s);
    add_to_term(3, res);
    flush_term(3);
}

function eval_affe() {
    var s = term0.getValue();
    Affe.eval(filename, s);
}


var exampleFileCache = { 'err': "(* Could not load file! *)" };

var builtinFileCache = { 'err': "(* Could not load file! *)" };

async function cacheFile(filePath) {
    fetch(filePath).then((contents) => {
        contents.text().then((val) => {
            exampleFileCache[filePath] = val;
        });
    }).catch((error) => {
        console.error(error);
    });
}

const builtinPath = s => `builtin/${s.charAt(0).toLowerCase()}${s.slice(1)}.ml`;

async function cacheBuiltin(moduleName) {
    let filePath = builtinPath(moduleName);
    fetch(filePath).then((contents) => {
        contents.text().then((val) => {
            builtinFileCache[filePath] = val;
        });
    }).catch((error) => {
        console.error(error);
    });
}

function loadBuiltin(moduleName) {
    let filePath = builtinPath(moduleName);
    if (builtinFileCache.hasOwnProperty(filePath)) {
        let val = builtinFileCache[filePath];
        return `module ${moduleName} = struct\n${val}\nend\n`;
    } else {
        return builtinFileCache.err;
    }
}

function loadExample(file) {
    if (exampleFileCache.hasOwnProperty(file)) {
        return exampleFileCache[file];
    } else {
        return exampleFileCache.err;
    }
}
