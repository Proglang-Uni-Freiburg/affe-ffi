# An OCaml-ffi for Affe

An adaptation of https://github.com/Drup/pl-experiments that adds an OCaml-ffi to Affe

## How to use

To translate an Affe file to OCaml, use `dune exec -- lang/affe/affe.exe <in file> -a <out file>`

Or simply use `make <name>.affe` to compile an example file from [lang/affe/affi/examples](lang/affe/affi/examples). Eg. `make example.affe`

Also take a look at the js-application at [www/](www/) where you can try out the same examples in a browser environment. When running locally, you may still want to host the application with a simple http-server. For example `python -m http.server`. 

Use `make vsc_extension` to install a vsc extension for simple syntax highlighting for the Affe language.


## What does the ffi add to Affe?

Have a look at [lang/affe/affi/examples/intro.affe](lang/affe/affi/examples/intro.affe)
