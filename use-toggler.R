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
# Load tidyverse to get more methods to handle the data
library(tidyverse)

# Check if the needed environment variables are set
# .Renviron for Rstudio
# .bashrc for R CMD
workspace <- Sys.getenv("TOGGL_WORKSPACE")
if (is.element("", workspace)) {
  stop("TOGGL_WORKSPACE is not a correct environment variable")
}
token <- Sys.getenv("TOGGL_TOKEN")
if (is.element("", token)) {
  stop("TOGGL_TOKEN needs to set as an environment variable")
}

# get the accessable groups in the workspace
groups <- as_tibble(get.toggl.groups(token, workspace))

groups.names <- length(groups$name)

if (!groups.names > 0) {
  stop("Did not find any groups for the workspace")
}

print(paste("Found", groups.names, "groups for that workspace"))
group <- as.integer(runif(1, min = 1, max = groups.names))
group.name <- groups$name[group]
group.id <- groups[groups$name == group.name, ]$id
print(paste("Fetching detail data for", group.name, "with group Id:", group.id))

group.detail.1w <- as_tibble(get.toggl.group.data(token, workspace, group.id, verbose = TRUE))
print(paste("Response is a table with", length(group.detail.1w), "columns and", length(group.detail.1w$id), "entries"))

