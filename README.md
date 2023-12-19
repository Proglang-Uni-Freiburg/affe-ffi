# affe-ffi

An adaptation of https://github.com/Drup/pl-experiments that adds an ocaml-ffi to affe

# How to use

To compile a file, use `dune exec -- lang/affe/affe.exe <in file> -a <out file>`

Or simply use `make <name>.affe` to compile an example file from [lang/affe/affi/examples](lang/affe/affi/examples). Eg. `make example.affe`

Also take a look at the js-application https://lukaskleinert.github.io/ where you can try out the same examples in a browser environment.

Use `make vsc_extension` to install an vsc extension for simple syntax highlighting for the affe language.
