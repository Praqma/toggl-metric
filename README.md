# toggl-metric
R library to fetch toggl data and generic methods to handle it.

## Use toggleR to fetch data from toggl

There are two different ways (at least) to use `toggleR`.

### Install from github

For local builds e.g. in Rstudio

```R
library(devtools)
#
#
# Using a local build is possible, see devtools::install_local()
#
# Better way is to get the source from github, since Jenkins will
# build and test every commit
#
# default value for ref in master, but can be any branch or tag
devtools::install_github('Praqma/toggleR', ref = 'master')
library(toggleR)
```

### Run R in a container

For every commit on master, a docker image is built and is stored on docker hub, to get `toggleR` base your build image on `praqma/toggler`.

```Dockerfile
FROM praqma/toggler
````

Simple example in `use-toggler.R`


