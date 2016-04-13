These are the docs that are served on http://escher-jl.org/

To (re)generate documentation, take the following steps.

Initial one-time set up:

- create a directory called `Escher/docs/build`
- copy `Escher/.git` directory to `Escher/docs/build`
- from `Escher/docs/build`, run `git checkout gh-pages` 

Generating docs (after initial setup):

- from `Escher/docs` run `sh make-docs.sh` to generate the docs, this will overwrite files in `Escher/docs/build`
- Now you can commit changes in `Escher/docs/build` directory (`gh-pages` branch) and push to github.

The basic idea is to use `Escher/docs/build` as an Escher repository checked out at `gh-pages`. Running `make-docs.sh` generates a new version of the docs.

