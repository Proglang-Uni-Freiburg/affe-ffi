# An OCaml-ffi for Affe

An adaptation of https://github.com/Drup/pl-experiments that adds an OCaml-ffi to Affe

## How to use

To translate an Affe file to OCaml, use `dune exec -- lang/affe/affe.exe <in file> -a <out file>`

Or simply use `make <name>.affe` to compile an example file from [lang/affe/affi/examples](lang/affe/affi/examples). Eg. `make example.affe`

Also take a look at the web application at [www/](www/) or [https://lukaskleinert.github.io/affe-ffi/](https://lukaskleinert.github.io/affe-ffi/) where you can try out the same examples in a browser environment. When running locally, you may still want to host the application with a simple http-server. For example `python -m http.server`.

Use `make vsc_extension` to install a vsc extension for very basic syntax highlighting for the Affe language.


## What does the ffi add to Affe?

Have a look at [lang/affe/affi/examples/intro.affe](lang/affe/affi/examples/intro.affe)

## Adding more example files

New .affe example files for the interactive web application can be added to the [lang/affe/affi/examples](lang/affe/affi/examples) folder. You then have to add the filename to the `l`-list in the file [lang/affe/affe_www.ml](lang/affe/affe_www.ml)

If you want to add a new "builtin" OCaml-module for the web application, you have to add that file (`.ml` file ending) to [www/builtin/](www/builtin/). You then have to add the module name (file basename starting with capital letter) to the `builtins`-list in the file [zoo/web/jsootop/jsootop.ml](zoo/web/jsootop/jsootop.ml)
